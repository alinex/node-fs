###
Copy Files
=================================================
This will copy a single file, complete directory or selection from directory.
It will make exact copies of the files as far as possible including times, ownership
and access modes. But if some of this rights are not possible to set it will be ignored
without an explicit error.

To select which files to copy you may specify it like in the {@link find.coffee find}
method. But the following options may be used:
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
  return console.error err if err
  console.log "Directory copied!"
```

Or to copy all js files and overwrite existing:

``` coffee
fs = require 'alinex-fs'
fs.copy '/tmp/some/directory', '/new/destination',
  includes: '*.js'
  overwrite: true
, (err) ->
  return console.error err.message if err
  console.log "Directory copied!"
```
###


# Node Modules
# -------------------------------------------------
debug = require('debug')('fs:copy')
fs = require 'fs'
path = require 'path'
async = require 'async'
posix = require 'posix'
# include other extended commands and helper
mkdirs = require './mkdirs'
filter = require '../helper/filter'


# Setup
# ------------------------------------------------
# Maximum parallel processes is half of the soft limit for open files if not given
# in the options.
PARALLEL = Math.floor posix.getrlimit('nofile').soft / 2


# Exported Methods
# ------------------------------------------------

###
@param {String} source path or file to be copied
@param {String} target file or directory to copy to
@param {Array<Object>|Object} [options] specifications for check defining which files
to copy
@param {function(Error, Array<String>)} [cb] callback with list of newly created
files and directly created directories or possible `Èrror`:
- Target file already exists
@internal The `depth` parameter is only used internally.
@param {Integer} [depth=0] current depth in file tree
###
module.exports.copy = (source, target, options, cb, depth = 0) ->
  unless cb?
    cb = ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  list = []
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
          target = target + task.source[source.length..]
          if stats.isFile()
            return cb() unless ok
            # create directory if necessary
            mkdirs.mkdirs path.dirname(target), (err) ->
              return cb err if err
              # copy the file
              fs.exists target, (exists) ->
                if exists and not (options.overwrite or options.ignore)
                  return cb new Error "Target file already exists."
                if not exists or options.overwrite
                  debug "copying file #{task.source} to #{target}"
                  list.push target
                  return copyFile task.source, stats, target, cb
                cb()
          else if stats.isSymbolicLink()
            return cb() unless ok
            # create directory if necessary
            mkdirs.mkdirs path.dirname(target), (err) ->
              return cb err if err
              debug "copying link #{task.source} to #{target}"
              fs.readlink task.source, (err, resolvedPath) ->
                return cb err if err
                # make the symlink
                list.push target
                fs.symlink resolvedPath, target, cb
          else
            # source is directory
            debug "going deeper into #{task.source} directory"
            task.depth++
            fs.readdir task.source, (err, files) ->
              return cb err if err
              # collect files from each subentry
              for file in files
                queue.push
                  source: "#{task.source}/#{file}"
                  depth: task.depth
            return cb() if options.noempty
            # create directory if necessary
            list.push target
            mkdirs.mkdirs target, cb
  , options.parallel ? PARALLEL
  # add current file
  queue.push
    source: source
    depth: depth
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
@param {Array<Object>|Object} [options] specifications for check defining which files to copy
@throws {Error} if anything out of order happened
- Target file already exists
@return {Array<String>} list of newly created files and directly created directories
@internal The `depth` parameter is only used internally.
@param {Integer} [depth=0] current depth in file tree
###
copySync = module.exports.copySync = (source, target, options = {}, depth = 0) ->
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  try
    stats = stat source
  catch error
    return if options.ignoreErrors
    throw error
  list = []
  ok = filter.filterSync source, depth, options
  if stats.isFile()
    return unless ok
    # create directory if neccessary
    mkdirs.mkdirsSync path.dirname(target)
    # copy the file
    exists = fs.existsSync target
    if exists and not (options.overwrite or options.ignore)
      throw new Error "Target file already exists."
    if not exists or options.overwrite
      debug "copying file #{source} to #{target}"
      list.push target
      return copyFileSync source, stats, target
  else if stats.isSymbolicLink()
    return unless ok
    # create directory if neccessary
    mkdirs.mkdirsSync path.dirname(target)
    resolvedPath = fs.readlinkSync source
    # make the symlink
    debug "copying link #{source} to #{target}"
    fs.symlinkSync resolvedPath, target
  else
    # source is directory
    depth++
    # copy directory
    if ok and not options.noempty
      list.push target
      mkdirs.mkdirsSync target, stats.mode
    # copy all files in directory
    debug "copying directory #{source} to #{target}"
    for file in fs.readdirSync source
      copySync path.join(source, file), path.join(target, file), options, depth

# Helper Methods
# -------------------------------------------------------

# @param {String} source dourcepath of concrete file to copy
# @param {fs.Stats} stats file information object
# @param {String} target path to store file copy to
# @param {function(<Error>)} cb callback after dann with possible `Error` object
copyFile = (source, stats, target, cb) ->
  # finalize only once
  done = (err) ->
    unless cbCalled
      return cb err if err
      # fix file permissions and times but ignore errors
      fs.utimes target, stats.atime, stats.mtime, ->
        fs.chown target, stats.uid, stats.gid, ->
          fs.chmod target, stats.mode, ->
            return cb()
    cbCalled = true
  # open streams
  rs = fs.createReadStream source
  ws = fs.createWriteStream target,
    mode: stats.mode
  # copy data
  ws.on 'error', done
  ws.on 'close', done
  rs.pipe ws

# @param {String} source dourcepath of concrete file to copy
# @param {fs.Stats} stats file information object
# @param {String} target path to store file copy to
# @throws {Error} if something went wrong
copyFileSync = (source, stats, target) ->
  # copy file
  fs.writeFileSync target, fs.readFileSync source
  # copy permissions and times
  fs.utimesSync target, stats.atime, stats.mtime
  fs.chownSync target, stats.uid, stats.gid
  fs.chmodSync target, stats.mode


###
Debugging
---------------------------------------------------------
This module uses the {@link debug} module so you may anytime call your app with
the environment setting `DEBUG=fs:copy` for the output of this method only.

Because there are `mkdirs` subcalls here you see the output of `DEBUG=fs:*` while
copying a small directory:

    fs:copy check test/temp/dir3 +32ms
    fs:copy going deeper into test/temp/dir3 directory +1ms
    fs:mkdirs directory /home/alex/github/node-fs/test/temp/dir4? +0ms
    fs:copy check test/temp/dir3/file11 +0ms
    fs:mkdirs directory /home/alex/github/node-fs/test/temp/dir4 created +0ms
    fs:mkdirs directory /home/alex/github/node-fs/test/temp/dir4? +0ms
    fs:mkdirs -> directory /home/alex/github/node-fs/test/temp/dir4 was already there +0ms
    fs:copy copying file test/temp/dir3/file11 to test/temp/dir4/file11 +0ms
###
