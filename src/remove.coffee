# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
async = require 'async'

# internal helper methods
filter = require './filter'

# Remove path recursively
# -------------------------------------------------
# This method will remove the given `path` entry and if it is a directory it
# will also remove any containing data.
#
# __Arguments:__
#
# * `path`
#   File or directory to be removed.
# * `options`
#   Specification of files to find.
# * `callback(err, removed)`
#   The callback will be called just if an error occurred. It returns the
#   file entry which was removed, if any.
# * `depth`
#   Search depth as integer (internal parameter).
#
# The option `maxdepth` is only supported in the search, but if a directory is
# matched everything within will be deleted.
remove = module.exports.async = (file, options, cb, depth = 0) ->
  unless cb?
    cb = ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  # check file entry
  stat = if options.dereference? then fs.stat else fs.lstat
  stat file, (err, stats) ->
    # return if already removed
    return cb() if err?.code is 'ENOENT'
    return cb err if err
    # Check the current file through filter options
    filter.async file, depth, options, (ok) ->
      if stats.isFile()
        return cb() unless ok
        # remove file
        fs.unlink file, (err) ->
          return cb err if err
          cb null, file
      else if stats.isSymbolicLink()
        return cb() unless ok
        # remove symbolic link
        fs.unlink file, (err) ->
          return cb err if err
          cb null, file
      else if stats.isDirectory()
        # file is directory
        dir = file
        depth++
        # if this dir should be removed, use no filtering for the containing parts
        options = {} if ok
        fs.readdir file, (err, files) ->
          return cb err if err
          # copy all files in directory
          async.each files, (file, cb) ->
            remove path.join(dir, file), options, cb, depth
          , (err) ->
            return cb err if err
            return cb() unless ok
            # remove directory itself
            fs.rmdir dir, (err) ->
              # remove file, if dir is a symbolic link
              fs.unlink dir, (err) ->
                cb null, dir
      else
        cb new Error "Entry '#{file}' is no directory, file or symbolic link."


# Remove path recursively (Synchronous)
# -------------------------------------------------
# Removes the given path and any containing files or subdirectories.
#
# __Arguments:__
#
# * `path`
#   File or directory to create if not existing.
# * `options`
#   Specification of files to find.
#
# __Return:__
#
# * `removed`
#   Returns the file entry which was removed.
#
# __Throw:__
#
# * `Error`
#   If anything out of order happened.
removeSync = module.exports.sync = (file, options = {}, depth = 0) ->
  # get parameter and default values
  file = path.resolve file
  # check file entry
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  try
    stats = stat file
  catch err
    # return if already removed
    return if err.code is 'ENOENT'
  # Check the current file through filter options
  ok = filter.sync file, depth, options
  if stats.isFile()
    return unless ok
    # remove file
    fs.unlinkSync file
    return file
  else if stats.isSymbolicLink()
    return unless ok
    # remove symbolic link
    fs.unlinkSync file
    return file
  else if stats.isDirectory()
    # file is directory
    dir = file
    depth++
    # if this dir should be removed, use no filtering for the containing parts
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
