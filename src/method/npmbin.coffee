###
Find Binary
=================================================
This will search a binary in the NPM modules directories.

Find the defined binary in node_modules directories. It will search in the current
and upper package directories.

__Example:__

``` coffee
fs = require 'alinex-fs'
fs.npmbin 'coffee', (err, cmd) ->
  console.log "Coffee command found at:" + cmd
```
###


# Node Modules
# -------------------------------------------------
fs = require 'fs'
path = require 'path'
debug = require('debug')('fs:npmbin')


# Exported Methods
# ------------------------------------------------

###
@param {String} bin name of the binary to search for
@param {String} dir directory to start search from
@param {function(<Error>, <String>)} cb callback with an `Error` or the found binary's path
###
module.exports.npmbin = (bin, dir, cb) ->
  debug "Search binary #{bin} starting at #{dir}" if debug.enabled
  npmbin bin, dir, cb

###
@param {String} bin name of the binary to search for
@param {String} dir directory to start search from
@return {String} the found binary's path
@throws {Error} if binary could not be found
###
module.exports.npmbinSync = (bin, dir) ->
  debug "Search binary #{bin} starting at #{dir}" if debug.enabled
  return npmbinSync bin, dir


# Helper Methods
# --------------------------------------------

# @param {String} bin name of the binary to search for
# @param {String} dir directory to start search from
# @param {function(err, path)} cb callback with an `Error` or the found binary's path
npmbin = (bin, dir, cb) ->
  unless cb
    cb = dir
    dir = path.dirname __dirname
  file = path.join dir, 'node_modules', '.bin', bin
  # search for file
  fs.exists file, (exists) ->
    if exists
      debug "-> found at #{file}" if debug.enabled
      return cb null, file
    # find in parent
    parent = path.join dir, '..', '..'
    if parent is dir
      # find in global include path
      for dir in process.env.PATH.split /:/
        file = path.join dir, bin
        return cb null, file if fs.existsSync file
      return cb new Error "Could not find #{bin} program."
    npmbin bin, parent, cb

# @param {String} bin name of the binary to search for
# @param {String} dir directory to start search from
# @return {String} the found binary's path
# @throws {String} if binary could not be found
npmbinSync = (bin, dir) ->
  dir ?= path.dirname __dirname
  file = path.join dir, 'node_modules', '.bin', bin
  # search for file
  if fs.existsSync file
    debug "-> found at #{file}" if debug.enabled
    return file
  # find in parent
  parent = path.join dir, '..', '..'
  if parent is dir
    # find in global include path
    for dir in process.env.PATH.split /:/
      file = path.join dir, bin
      return file if fs.existsSync file
    throw new Error "Could not find #{bin} program."
  npmbinSync bin, parent
