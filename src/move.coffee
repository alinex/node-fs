# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
async = require 'async'
debug = require('debug')('fs:move')

# include other extended commands and helper
mkdirs = require './mkdirs'
copy = require './copy'
remove = require './remove'

# Move file or directory
# -------------------------------------------------
# This method will move a single file or complete directory like `mv` and will
# do so also over filesystem boundaries.
#
# __Arguments:__
#
# * `source`
#   File or directory to be moved.
# * `target`
#   File or directory to move to.
# * `options`
#   Specification of files to find.
# * `callback(err)`
#   The callback will be called just if an error occurred.
#
# __Additional Options:__
#
# * `overwrite`
#   if set to `true` it will not fail if destination file already exists and
#   overwrite it
# * `clean`
#   if set to `true` it will clean old files from target.
module.exports.async = (source, target, options = {}, cb = ->) ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  debug "Move filepath #{source} to #{target}."
  # collect methods to run
  async.series [
    # remove old target first
    (cb) ->
      return cb() unless options.clean
      remove.async target, cb
    # create parent directories
    (cb) ->
      mkdirs.async path.dirname(target), cb
    # try to rename file
    (cb) ->
      return cb() if options
      fs.rename source, target, (err) ->
        return cb() unless err
        copyRemove source, target, options, cb
    # direct copy/remove
    (cb) ->
      return cb() unless options
      copyRemove source, target, options, cb
  ], cb

copyRemove = (source, target, options, cb) ->
  # copy to target
  copy.async source, target, options, (err) ->
    return cb err if err
    # finally remove source
    remove.async source, options, cb


# Move file or directory (Synchronous)
# -------------------------------------------------
# This method will move a single file or complete directory like `mv`.
#
# __Arguments:__
#
# * `source`
#   File or directory to be moved.
# * `target`
#   File or directory to move to.
# * `options`
#   Specification of files to find.
#
# __Additional Options:__
#
# * `overwrite`
#   if set to `true` it will not fail if destination file already exists and
#   overwrite it
# * `clean`
#   if set to `true` it will clean old files from target.
#
# __Throw:__
#
# * `Error`
#   If anything out of order happened.
module.exports.sync = (source, target, options = {}) ->
  debug "Move filepath #{source} to #{target}."
  # remove old target first
  if options.clean
    remove.sync target
  # create parent directories
  mkdirs.sync path.dirname target
  # try to rename file
  unless options
    try
      fs.renameSync source, target
    catch err
      return unless err
      return copyRemoveSync source, target, options
  # direct copy/remove
  copyRemoveSync source, target, options

copyRemoveSync = (source, target, options) ->
  # copy to target
  copy.sync source, target, options
  # finally remove source
  remove.sync source, options
