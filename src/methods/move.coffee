###
Move
=================================================
This will move a single file, complete directory or selection from directory. This
is the same as copy the files and remove them afterwards.

To select which files to copy you may specify it like in the
[`find()`](find.coffee) method. But the following options may be used:

__Additional Options:__

* `overwrite` -
  if set to `true` it will not fail if destination file already exists and
   overwrite it
* `clean` -
  if set to `true` it will clean old files from target.
###


# Node Modules
# -------------------------------------------------
fs = require 'fs'
path = require 'path'
async = require 'async'
debug = require('debug')('fs:move')
# include other extended commands and helper
mkdirs = require './mkdirs'
copy = require './copy'
remove = require './remove'


# Exported Methods
# ------------------------------------------------

###
@param {String} source path or file to be copied
@param {String} target file or directory to copy to
@param {Object} [options] specifications for check defining which files to copy
@param {function(err)} [cb] callback which is called after done with possible `Èrror`
###
module.exports.move = (source, target, options = {}, cb = ->) ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  debug "move filepath #{source} to #{target}."
  # collect methods to run
  async.series [
    # remove old target first
    (cb) ->
      return cb() unless options.clean
      remove.remove target, cb
    # create parent directories
    (cb) ->
      mkdirs.mkdirs path.dirname(target), cb
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

###
@param {String} source path or file to be copied
@param {String} target file or directory to copy to
@param {Object} [options] specifications for check defining which files to copy
@throws {Error} if anything out of order happened
###
module.exports.moveSync = (source, target, options = {}) ->
  debug "move filepath #{source} to #{target}."
  # remove old target first
  if options.clean
    remove.removeSync target
  # create parent directories
  mkdirs.mkdirsSync path.dirname target
  # try to rename file
  unless options
    try
      fs.renameSync source, target
    catch error
      return unless error
      return copyRemoveSync source, target, options
  # direct copy/remove
  copyRemoveSync source, target, options


# Helper methods
# -------------------------------------------------

# @param {String} source path or file to be copied
# @param {String} target file or directory to copy to
# @param {Object} [options] specifications for check defining which files to copy
# @param {function(err)} [cb] callback which is called after done with possible `Èrror`
copyRemove = (source, target, options, cb) ->
  # copy to target
  copy.copy source, target, options, (err) ->
    return cb err if err
    # finally remove source
    remove.remove source, options, cb

# @param {String} source path or file to be copied
# @param {String} target file or directory to copy to
# @param {Object} [options] specifications for check defining which files to copy
# @throws {Error} if anything out of order happened
copyRemoveSync = (source, target, options) ->
  # copy to target
  copy.copySync source, target, options
  # finally remove source
  remove.removeSync source, options
