###
Move Files
=================================================
This will move a single file, complete directory or selection from directory. This
is the same as copy the files and remove them afterwards.

To select which files to copy and how to work you can use the following options:
- `filter` - `Array<Object>|Object` {@link filter.coffee}
- `clean` - `Boolean` if set to `true` it will clean old files from target.
- `overwrite` - `Boolean` if set to `true` it will not fail if destination file
  already exists and overwrite it
- `ignore` - `Boolean` it will not fail if destination file already exists
  but skip this and go on with the next file
- `noempty` - `Boolean` set to `true to don't create empty directories while no
  files to copy into`
- `dereference` - `Boolean` dereference symbolic links and go into them
- `ìgnoreErrors` - `Boolean` go on and ignore IO errors
- `parallel` - `Integer` number of maximum parallel calls in asynchronous run
  (defaults to half of open files limit per process on the system)


__Example:__

``` coffee
fs = require 'alinex-fs'
fs.copy '/tmp/some/directory', '/new/destination', (err) ->
  return console.error err.message if err
  console.log "Directory copied!"
```

You may also use options to specify which files within the source directory to
move.
###


# Node Modules
# -------------------------------------------------
debug = require('debug')('fs:move')
fs = require 'fs'
path = require 'path'
async = require 'async'
# include other extended commands and helper
mkdirs = require './mkdirs'
filter = require '../helper/filter'
copy = require './copy'
remove = require './remove'
parallel = require '../helper/parallel'


# Exported Methods
# ------------------------------------------------

###
@param {String} source path or file to be copied
@param {String} target file or directory to copy to
@param {Object} [options] specifications for check defining which files to copy
@param {function(<Error>)} [cb] callback which is called after done with possible `Èrror`
###
module.exports.move = (source, target, options = {}, cb = ->) ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  debug "move filepath #{source} to #{target}."
  list = []
  # clean target completely
  clean target,
    parallel: parallel(options)
    clean: options.clean
    ignoreErrors: options.ignoreErrors
    dereference: options.dereference
  , (err) ->
    return cb err if err and not options.ignoreErrors
    # create a queue
    queue = async.queue (task, cb) ->
      debug "check #{task.source}"
      async.setImmediate ->
        filter.filter task.source, task.depth, options, (ok) ->
          return cb() if ok is undefined
          # check source entry
          stat = if options.dereference? then fs.stat else fs.lstat
          stat task.source, (err, stats) ->
            if err
              return cb if options?.ignoreErrors then null else err
            dirTasks source, ok, stats, task, queue, (err) ->
              return cb err if err
              return cb() unless ok
              # move
              target = target + task.source[source.length..]
              mkdirs.mkdirs path.dirname(target), (err) ->
                return cb err if err and not options.ignoreErrors
                fs.exists target, (exists) ->
                  if exists and not options.overwrite
                    return cb new Error "target file #{target} already exists"
                  # try to rename
                  fs.rename source, target, (err) ->
                    unless err
                      debug "renamed #{source} -> #{target}"
                      list.push target
                      return cb()
                    # else copy and remove
                    copyRemove task.source, target,
                      overwrite: options.overwrite
                      ignore: options.ignore
                      ignoreErrors: options.ignoreErrors
                      dereference: options.dereference
                      parallel: parallel(options)
                    , (err) ->
                      unless err
                        debug "copied/removed #{source} -> #{target}"
                        list.push target
                      cb err
    , Math.sqrt parallel(options)
    # add current file
    queue.push
      source: source
      depth: 0
    # drain queue
    queue.drain = ->
      list.sort()
      cb null, list
    # some error occured, stop there
    queue.error = (err) ->
      queue.kill()
      cb err
      cb = ->

###
@param {String} source path or file to be copied
@param {String} target file or directory to copy to
@param {Object} [options] specifications for check defining which files to copy
@throws {Error} if anything out of order happened
@internal The `depth` parameter is only used internally.
@param {Integer} [depth=0] current depth in file tree
###
moveSync = module.exports.moveSync = (source, target, options = {}, depth = 0) ->
  debug "check #{source}"
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  list = []
  try
    stats = stat source
  catch error
    return list if options.ignoreErrors
    throw error
  # remove old target first
  if options.clean
    remove.removeSync target,
      ignoreErrors: options.ignoreErrors
      dereference: options.dereference
  # check what to do
  ok = filter.filterSync source, depth, options
  if stats.isDirectory() and not ok
    # source is directory and not moved -> check entries
    depth++
    # copy directory
    mkdirs.mkdirsSync target, stats.mode
    # copy all files in directory
    debug "moving directory #{source} to #{target}"
    for file in fs.readdirSync source
      list = list.concat moveSync path.join(source, file), path.join(target, file), options, depth
      list.sort()
      return list
  else
    return list unless ok
    try
      exists = fs.existsSync target
      if exists and not options.overwrite
        throw new Error "target file #{target} already exists"
      fs.renameSync source, target
      debug "renamed #{source} -> #{target}"
      list.push target
      return list
    catch error
      throw error unless options.ignoreErrors
      copyRemoveSync source, target,
        overwrite: options.overwrite
        ignore: options.ignore
        ignoreErrors: options.ignoreErrors
        dereference: options.dereference
      debug "copied/removed #{source} -> #{target}"
      list.push target
      return list


# Helper methods
# -------------------------------------------------

# @param {String} source path or file to be copied
# @param {Object} [options] specifications for check defining which files to copy
# @param {function(Error)} [cb] callback which is called after done with possible `Èrror`
clean = (source, options, cb) ->
  return cb() unless options.clean
  remove.remove source, options, cb

# Add tasks to queue for each file in directory if not ok to move.
#
# @param {String} source path or file to be copied
# @param {Boolean} ok result from {@link find()}
# @param {fs.Stats} stats file information of node
# @param {Object} task the current task with:
# - `source` - `String` directory to read
# - `depth` - `Integer` depth of directory
# @param {async.Queue} queue the current queue to check on filesystem
# @param {function(<Error>)} cb callback with error if something went wrong
dirTasks = (source, ok, stats, task, queue, cb) ->
  return cb() unless stats.isDirectory and not ok
  task.depth++
  fs.readdir task.source, (err, files) ->
    return cb err if err
    # collect files from each subentry
    for file in files
      queue.push
        source: "#{task.source}/#{file}"
        depth: task.depth
    return cb()

# @param {String} source path or file to be copied
# @param {String} target file or directory to copy to
# @param {Object} [options] specifications for check defining which files to copy
# @param {function(Error, Boolean)} [cb] callback which is called after done with
# possible `Èrror` and `true` if file could be moved
copyRemove = (source, target, options, cb) ->
  copy.copy source, target, options, (err, list) ->
    return cb err if err
    list.reverse()
    async.eachLimit list, options.parallel, (file, cb) ->
      remove.remove file, options, cb
    , cb


# @param {String} source path or file to be copied
# @param {String} target file or directory to copy to
# @param {Object} [options] specifications for check defining which files to copy
# @throws {Error} if anything out of order happened
copyRemoveSync = (source, target, options) ->
  # copy to target
  copy.copySync source, target, options
  # finally remove source
  remove.removeSync source, options


###
Debugging
---------------------------------------------------------
This module uses the {@link debug} module so you may anytime call your app with
the environment setting `DEBUG=fs:move` for the output of this method only.

Because there are `mkdirs` subcalls here you see the output of `DEBUG=fs:*` while
removeing a small directory:

    fs:move move filepath test/temp/dir1 to test/temp/dir4. +26ms
    fs:move check test/temp/dir1 +0ms
    fs:filter skip  because path not included +7ms
    fs:filter test/temp/dir1 SKIP +0ms
    fs:move check test/temp/dir1/file11 +0ms
    fs:filter test/temp/dir1/file11 OK +2ms
    fs:mkdirs directory /home/alex/github/node-fs/test/temp/dir4? +0ms
    fs:mkdirs directory /home/alex/github/node-fs/test/temp/dir4 created +0ms
    fs:move renamed test/temp/dir1 -> test/temp/dir4/file11 +0ms
###
