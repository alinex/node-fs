###
Change Rights
=================================================
Change the ownership of path like fs.chmod but recursively.

The options are the same as used for find with the additional mode:
- `mode`
###


# Node Modules
# -------------------------------------------------
fs = require 'fs'
path = require 'path'
async = require 'async'
debug = require('debug')('fs:chmods')


# Exported Methods
# ------------------------------------------------

###
@param {String} file file path or directory to search
@param {Object} options selection of files to search and mode
@param {function(<Error>)} cb callback with error if something went wrong
###
chmods = module.exports.chmods = (file, options, cb = ->) ->
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

###
@param {String} file file path or directory to search
@param {Object} options selection of files to search and mode
@throws {Error} if something went wrong
###
chmodsSync = module.exports.chmodsSync = (file, options) ->
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
