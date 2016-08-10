###
Change Ownership
=================================================
Recursive change file ownership like {@link fs.chown}.

The options object is the same as used for {@link find.coffee} with the additional mode:
- `uid` - `Integer` - user id to set
- `gid` - `Integer` - group id to set
- `dereference` - `Boolean`
- `ignoreErrors` - `Boolean`
###


# Node Modules
# -------------------------------------------------
fs = require 'fs'
path = require 'path'
async = require 'async'
debug = require('debug')('fs:chowns')


# Exported Methods
# ------------------------------------------------

###
@param {String} file file path or directory to search
@param {Object} options selection of files to search and user/group id
@param {function(<Error>)} cb callback with error if something went wrong
###
chowns = module.exports.chowns = (file, options, cb = ->) ->
  # check file entry
  stat = if options.dereference? then fs.stat else fs.lstat
  stat file, (err, stats) ->
    # return if not existing
    if err
      return cb() if err.code is 'ENOENT' or options.ignoreErrors
      return cb err
    # change inode ownership
    fs.chown file, options.uid, options.gid, (err) ->
      return cb err if err
      return cb() unless stats.isDirectory()
      # do the same for contents of directory
      dir = file
      debug "chown directory contents of #{dir}"
      fs.readdir file, (err, files) ->
        return cb err if err
        # remove all files in directory
        async.each files, (file, cb) ->
          chowns path.join(dir, file), options, cb
        , cb

###
@param {String} file file path or directory to search
@param {Object} options selection of files to search and user/group id
@throws {Error} if something went wrong
###
chownsSync = module.exports.async = (file, options) ->
  # check file entry
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  try
    stats = stat file
  catch error
    # return if already removed
    return if error.code is 'ENOENT' or options.ignoreErrors
    throw error
  # change inode ownership
  fs.chownSync file, options.uid, options.gid
  return unless stats.isDirectory()
  # do the same for contents of directory
  dir = file
  debug "chown directory contents of #{dir}"
  # remove all files in directory
  for file in fs.readdirSync dir
    chownsSync path.join(dir, file), options
