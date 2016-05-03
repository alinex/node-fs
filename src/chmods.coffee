# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
async = require 'async'
debug = require('debug')('fs:chmods')


# Chown
# -------------------------------------------------
# Change the ownership of path like fs.chmod but recursively.
#
# __Arguments:__
#
# * `path`
#   File or directory to be changed
# * `options`
#   Specification of files to find.
#
#   - `mode`
#   - `dereference` (boolean)
#
# * `callback(err)`
#   The callback will be called just if an error occurred.
chmods = module.exports.async = (file, options, cb = ->) ->
  # check file entry
  stat = if options.dereference? then fs.stat else fs.lstat
  stat file, (err, stats) ->
    # return if not existing
    if err
      return cb() if err.code is 'ENOENT' or options.ignoreErrors
      return cb err
    # change inode ownership
    fs.chmod file, options.mode, (err) ->
      return cb err if err
      return cb() unless stats.isDirectory()
      # do the same for contents of directory
      dir = file
      debug "chmod directory contents of #{dir}"
      fs.readdir file, (err, files) ->
        return cb err if err
        # remove all files in directory
        async.each files, (file, cb) ->
          chmods path.join(dir, file), options, cb
        , cb

# Remove path recursively (Synchronous)
# -------------------------------------------------
# Removes the given path and any containing files or subdirectories.
#
# __Arguments:__
#
# * `path`
#   File or directory to be changed
# * `options`
#   Specification of files to find.
#
#   - `uid`
#   - `gid`
#   - `dereference` (boolean)
#
# __Throw:__
#
# * `Error`
#   If anything out of order happened.
chmodsSync = module.exports.async = (file, options) ->
  # check file entry
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  try
    stats = stat file
  catch error
    # return if already removed
    return if error.code is 'ENOENT' or options.ignoreErrors
    throw error
  # change inode ownership
  fs.chmodSync file, options.mode
  return unless stats.isDirectory()
  # do the same for contents of directory
  dir = file
  debug "chmod directory contents of #{dir}"
  # remove all files in directory
  for file in fs.readdirSync dir
    chmodsSync path.join(dir, file), options
