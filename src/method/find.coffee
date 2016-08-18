###
Find Files
=================================================
This is a powerfull method to search for files on the local filesystem. It works
recursively with multiple checks and to get a file list as quick as possible.

To define which files to select you may use the following options::
- `filter` - `Array<Object>|Object` {@link filter.coffee}
- `dereference` - `Boolean` dereference symbolic links and go into them
- `ìgnoreErrors` - `Boolean` go on and ignore IO errors
- `parallel` - `Integer` number of maximum parallel calls in asynchronous run
  (defaults to half of open files limit per process on the system)

To not completely exhaust the system or the allowed open files per process use the
parallel limit but because this runs recursively the square root of the given value
is used for the first and less for each other level of depth.

__Example:__

``` coffee
fs = require 'alinex-fs'
fs.find '/tmp/some/directory',
  filter:
    include: '*.jpg'
, (err, list) ->
  return console.error err if err
  console.log "Found " + list.length + " images."
  # do something with list
```
###


# Node Modules
# -------------------------------------------------
debug = require('debug')('fs:find')
fs = require 'fs'
path = require 'path'
async = require 'async'
# helper modules
filter = require '../helper/filter'
parallel = require '../helper/parallel'


# Exported Methods
# ------------------------------------------------

###
@param {String} search source path to be searched in
@param {Object} [options] specifications for check defining which files to list
@param {function(Error, Array)} [cb] callback which is called after done with an `Èrror`
or the complete list of files found as `Àrray`
###
module.exports.find = (source, options, cb) ->
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
          list.push task.source if ok
          return cb null, list unless stats.isDirectory()
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
            cb()
  , parallel(options)
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
@param {String} search source path to be searched in
@param {Object} [options] specifications for check defining which files to list
@return {Array} complete list of files found
@throws {Error} if anything out of order happened
@internal The `depth` parameter is only used internally.
@param {Integer} [depth=0] current depth in file tree
###
findSync = module.exports.findSync = (source, options = {}, depth = 0) ->
  list = []
  ok = filter.filterSync source, depth, options
  return list if options.lazy and not ok
  # Check the current file through filter options
  list.push source if ok
  # check source entry
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  try
    stats = stat source
  catch error
    return list if options.ignoreErrors
    throw error
  return list unless stats.isDirectory()
  # source is directory
  depth++
  files = fs.readdirSync source
  # collect files from each subentry
  for file in files.sort()
    list = list.concat findSync path.join(source, file), options, depth
  return list


###
Debugging
---------------------------------------------------------
This module uses the {@link debug} module so you may anytime call your app with
the environment setting `DEBUG=fs:find` for the output of this method only.

    fs:find check test/temp +0ms
    fs:filter skip test/temp because path not included +5ms
    fs:filter test/temp SKIP +1ms
    fs:find going deeper into test/temp directory +40ms
    fs:find check test/temp/dir1 +1ms
    fs:find check test/temp/dir2 +0ms
    fs:find check test/temp/dir3 +0ms
    fs:find check test/temp/file1 +0ms
    fs:find check test/temp/file2 +0ms
    fs:filter test/temp/dir1 OK +1ms
    fs:filter skip dir2 because path not included +0ms
    fs:filter test/temp/dir2 SKIP +0ms
    fs:filter skip dir3 because path not included +0ms
    fs:filter test/temp/dir3 SKIP +0ms
    fs:filter test/temp/file1 OK +0ms
    fs:filter skip file2 because path not included +0ms
    fs:filter test/temp/file2 SKIP +0ms
    fs:find going deeper into test/temp/dir1 directory +0ms
    fs:find going deeper into test/temp/dir2 directory +0ms
    fs:find check test/temp/dir1/file11 +1ms
    fs:filter test/temp/dir1/file11 OK +0ms
###
