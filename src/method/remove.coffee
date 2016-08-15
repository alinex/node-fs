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
remove = module.exports.remove = (file, options, cb, depth = 0) ->
  unless cb?
    cb = ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  # check file entry
  stat = if options.dereference? then fs.stat else fs.lstat
  stat file, (err, stats) ->
    # return if already removed
    if err
      return cb() if err.code is 'ENOENT' or options.ignoreErrors
      return cb err
    # Check the current file through filter options
    filter.filter file, depth, options, (ok) ->
      if stats.isFile()
        return cb() unless ok
        # remove file
        debug "removing file #{file}"
        fs.unlink file, (err) ->
          return cb err if err and err.code isnt 'ENOENT'
          cb null, file
      else if stats.isSymbolicLink()
        return cb() unless ok
        # remove symbolic link
        debug "removing link #{file}"
        fs.unlink file, (err) ->
          return cb err if err and err.code isnt 'ENOENT'
          cb null, file
      else if stats.isDirectory()
        # file is directory
        dir = file
        depth++
        # if this dir should be removed, use no filtering for the containing parts
        debug "removing directory #{dir}"
        options = {} if ok
        fs.readdir file, (err, files) ->
          return cb err if err
          # remove all files in directory
          async.each files, (file, cb) ->
            remove path.join(dir, file), options, cb, depth
          , (err) ->
            return cb err if err
            return cb() unless ok
            # remove directory itself
            fs.rmdir dir, (err) ->
              return cb err if err and err.code isnt 'ENOTDIR'
              # remove file, if dir is a symbolic link
              fs.unlink dir, (err) ->
                return cb err if err and err.code isnt 'ENOENT'
                cb null, dir
      else
        cb new Error "Entry '#{file}' is no directory, file or symbolic link."


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
