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
# * `callback(err)`
#   The callback will be called just if an error occurred.
move = module.exports.async = (source, target, cb) ->
  debug "Move filepath #{source} to #{target}."
  # create parent directories
  mkdirs.async path.basedir(target), (err) ->
    return cb err if err
    # try to rename file
    fs.rename source, target, (err) ->
      # done if no error
      return cb() unless err
      # remove target
      remove.async target, (err) ->
        return cb err if err
        # copy to target
        copy.async source, target, (err) ->
          return cb err if err
          # finally remove source
          remove.async source, cb

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
#
# __Throw:__
#
# * `Error`
#   If anything out of order happened.
moveSync = module.exports.sync = (source, target) ->
  debug "Move filepath #{source} to #{target}."
  # create parent directories
  mkdirs.sync path.basedir target
  # try to rename file
  try
    fs.rename source, target
  catch err
    # remove target
    remove.sync target
    # copy to target
    copy.sync source, target
    # finally remove source
    remove.sync source
