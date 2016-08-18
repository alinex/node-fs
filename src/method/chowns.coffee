###
Change Ownership
=================================================
Recursive change file ownership like {@link fs.chown}.

The options object is the same as used for {@link find.coffee} with the additional mode:
- `user` - `String|Integer` - user name or id to set
- `group` - `String|Integer` - group name or id to set
- `dereference` - `Boolean` dereference symbolic links and go into them
- `ìgnoreErrors` - `Boolean` go on and ignore IO errors
###


# Node Modules
# -------------------------------------------------
debug = require('debug')('fs:chowns')
fs = require 'fs'
async = require 'async'
posix = require 'posix'
# include other extended commands and helper
find = require './find'
parallel = require '../helper/parallel'


# Exported Methods
# ------------------------------------------------

###
@param {String} source file path or directory to search
@param {Object} options selection of files to search and user/group id
@param {function(Error)} cb callback with error if something went wrong
- No file to change owner for found!
###
module.exports.chmods = (source, options, cb = ->) ->
  find.find source, options, (err, list) ->
    return cb err if err
    unless list.length or options.ignoreErrors
      return cb new Error "No file to change owner for found!"
    try
      uid = getUid options
      gid = getGid options
    catch error
      return cb error unless options.ignoreErrors
    async.eachLimit list, parallel(options), (file, cb) ->
      debug "chown of #{file}"
      fs.chown file, uid, gid, cb
    , (err) ->
      cb err, list

###
@param {String} source file path or directory to search
@param {Object} options selection of files to search and user/group id
@throws {Error} if something went wrong
- No file to change owner for found!
###
module.exports.chmodsSync = (source, options) ->
  list = find.findSync source, options
  unless list.length or options.ignoreErrors
    return new Error "No file to change owner for found!"
  try
    uid = getUid options
    gid = getGid options
  catch error
    throw error unless options.ignoreErrors
  for file in list
    fs.chownSync file, uid, gid
  return list


# Helper Methods
# ------------------------------------------------

# @param {Object} options selection with user/group to set
# @return {Integer} user id or `undefined` if not set
getUid = (options) ->
  if options.user and not isNaN options.user
    return posix.getpwnam(options.user).uid
  return options.user

# @param {Object} options selection with user/group to set
# @return {Integer} group id or `undefined` if not set
getGid = (options) ->
  if options.group and not isNaN options.group
    return posix.getgrnam(options.group).gid
  return options.group
