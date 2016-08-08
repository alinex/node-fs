###
Touch File
=================================================
The touch methods allow the following options:
- `reference` - file path used as reference
- `time` - time to use
- `mtime` - use this time (defauklts to current time)
- `noCreate` - don't create file if not existing
- `noAccess` - don't change access time of the file
- `noModified` - don't change modified time of the file
###


# Node Modules
# -------------------------------------------------
fs = require 'fs'


# Exported Methods
# ------------------------------------------------

###
@param {String} file to be changed
@param {Object} [options] see description above
@param {function(<Error>)} cb callback with `Error` if sometzhing went wrong
###
touch = module.exports.touch = (file, options = {}, cb = ->) ->
  if typeof options is 'function'
    cb = options
    options = {}
  # optional arguments
  options.time ?= new Date()
  atime = mtime = options.time
  mtime = options.mtime if options.mtime
  if options.reference
    return fs.stat options.reference, (err, stats) ->
      return cb err if err
      touch file,
        time: stats.atime
        mtime: stats.mtime
        noCreate: options.noCreate
      , cb
  # don't change some times
  if options.noAccess or options.noModified
    atime = null if options.noAccess
    atime = null if options.noModified
    return fs.stat file, (err, stats) ->
      return cb err if err
      touch file,
        time: atime ? stats.atime
        mtime: mtime ? stats.mtime
        noCreate: options.noCreate
      , cb
  # do the touch
  fs.exists file, (exists) ->
    return cb() if exists or options.noCreate
    fs.open file, 'a', (err, fd) ->
      return cb err if err
      fs.close fd, (err) ->
        return cb err if err
        fs.utimes file, atime, mtime, cb

###
@param {String} file to be changed
@param {Object} [options] see description above
@throws {Error} if sometzhing went wrong
###
touchSync = module.exports.touchSync = (file, options = {}) ->
  # optional arguments
  options.time ?= new Date()
  atime = mtime = options.time
  mtime = options.mtime if options.mtime
  if options.reference
    stats = fs.statSync options.reference
    return touchSync file,
      time: stats.atime
      mtime: stats.mtime
      noCreate: options.noCreate
  # don't change some times
  if options.noAccess or options.noModified
    atime = null if options.noAccess
    atime = null if options.noModified
    stats = fs.statSync file
    return touchSync file,
      time: atime ? stats.atime
      mtime: mtime ? stats.mtime
      noCreate: options.noCreate
  # do the touch
  return if fs.existsSync(file) or options.noCreate
  fs.closeSync fs.openSync file, 'a'
  fs.utimesSync file, atime, mtime
