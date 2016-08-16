###
Remove Files
=================================================
This method will remove the given `path` entry and if it is a directory it
will also remove any containing data or only the selection of files.

The option `maxdepth` is only supported in the search, but if a directory is
matched everything within will be deleted.

This method will remove the given `path` entry and if it is a directory it
will also remove any containing data. If some filter given you can also delete#
selectively.

To select which files to remove the following options may be used:
- `filter` - `Array<Object>|Object` {@link filter.coffee}
- `dereference` - `Boolean` dereference symbolic links and go into them
- `ìgnoreErrors` - `Boolean` go on and ignore IO errors
- `parallel` - `Integer` number of maximum parallel calls in asynchronous run
  (defaults to half of open files limit per process on the system)

__Example:__

``` coffee
fs = require 'alinex-fs'
fs.remove '/tmp/some/directory', (err, removed) ->
  return console.error err if err
  if removed
    console.log "Directory '"+removed+"' was removed with all it's contents."
  console.log "Directory no longer exists!"
```
###


# Node Modules
# -------------------------------------------------
debug = require('debug')('fs:remove')
path = require 'path'
async = require 'async'
fs = require 'fs'
posix = require 'posix'
# internal helper methods
filter = require '../helper/filter'
find = require './find'


# Setup
# ------------------------------------------------
# Maximum parallel processes is half of the soft limit for open files if not given
# in the options.
PARALLEL = Math.floor posix.getrlimit('nofile').soft / 2


# Exported Methods
# ------------------------------------------------

###
@param {String} path directory or file to be deleted
@param {Object} [options] specifications for check defining which files to remove
@param {function(Error, String)} [cb] callback which is called after done with possible
       `Èrror` or with the file/directory deleted
@internal The `depth` parameter is only used internally.
@param {Integer} [depth=0] current depth in file tree
###
module.exports.remove = (path, options, cb, depth = 0) ->
  unless cb?
    cb = ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  # get list through filter
  find.find path, options, (err, list) ->
    if err
      return cb() if err.code is 'ENOENT' or options.ignoreErrors
      return cb err
    # remove all entries in list
    list.reverse()
    async.eachSeries list, (file, cb) ->
      return cb err if err
      removeFile file, options, (err) ->
        return cb() if err and (err.code is 'ENOENT' or options.ignoreErrors)
        cb err
    , (err) ->
      return cb err if err
      # resturn list as result
      cb null, list


###
@param {String} path directory or file to be deleted
@param {Object} [options] specifications for check defining which files to remove
@return {String} the file or directory deleted
@throws {Error} if domething went wrong
@internal The `depth` parameter is only used internally.
@param {Integer} [depth=0] current depth in file tree
###
removeSync = module.exports.removeSync = (file, options = {}, depth = 0) ->
  # get parameter and default values
  file = path.resolve file
  # check file entry
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  try
    stats = stat file
  catch error
    # return if already removed
    return if error.code is 'ENOENT' or options.ignoreErrors
    throw error
  # Check the current file through filter options
  ok = filter.filterSync file, depth, options
  if stats.isFile()
    return unless ok
    # remove file
    debug "removing file #{file}"
    fs.unlinkSync file
    return file
  else if stats.isSymbolicLink()
    return unless ok
    # remove symbolic link
    debug "removing link #{file}"
    fs.unlinkSync file
    return file
  else if stats.isDirectory()
    # file is directory
    dir = file
    depth++
    # if this dir should be removed, use no filtering for the containing parts
    debug "removing directory #{file}"
    options = {} if ok
    files = fs.readdirSync file
    # copy all files in directory
    for file in files
      removeSync path.join(dir, file), options, depth
    return unless ok
    # remove directory itself
    try fs.rmdirSync dir
    # remove file, if dir is a symbolic link
    try fs.unlinkSync dir
    return dir
  else
    throw new Error "Entry '#{file}' is no directory, file or symbolic link."


# Helper Methods
# -------------------------------------------------------

# @param {String} source dourcepath of concrete file to copy
# @param {Object} [options] specifications for check defining which files to remove
# @param {function(Error)} cb callback after dann with possible `Error` object
# @throw {Error} Entry 'xxxxxx' is no directory, file or symbolic link.
removeFile = (source, options, cb) ->
  stat = if options.dereference? then fs.stat else fs.lstat
  stat source, (err, stats) ->
    return cb() if err and (err.code is 'ENOENT' or options.ignoreErrors)
    if stats.isFile()
      # remove file
      debug "removing #{source} (file)"
      fs.unlink source, cb
    else if stats.isSymbolicLink()
      # remove symbolic link
      debug "removing #{source} (link)"
      fs.unlink source, cb
    else if stats.isDirectory()
      # remove directory
      debug "removing #{source} (directory)"
      fs.readdir source, (err, files) ->
        return cb err if err
        async.eachLimit files, (options.parallel ? PARALLEL), (file, cb) ->
          removeFile file, options, cb
        , (err) ->
          return cb err if err
          # remove directory itself
          fs.rmdir source, (err) ->
            if err?.code is 'ENOTDIR'
              return fs.unlink source, cb
            cb err
    else
      cb new Error "Entry '#{source}' is no directory, file or symbolic link."


###
Debugging
---------------------------------------------------------
This module uses the {@link debug} module so you may anytime call your app with
the environment setting `DEBUG=fs:remove` for the output of this method only.

Because there are `mkdirs` subcalls here you see the output of `DEBUG=fs:*` while
removeing a small directory:

    fs:find check test/temp/dir3 +24ms
    fs:find going deeper into test/temp/dir3 directory +0ms
    fs:find check test/temp/dir3/file11 +0ms
    fs:remove removing test/temp/dir3/file11 (file) +1ms
    fs:remove removing test/temp/dir3 (directory) +0ms
###
