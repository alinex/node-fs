# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
# include other extended commands and helper


# Touch a file
# -------------------------------------------------
# __Arguments:__
#
# - `file` - path under which the directory should be created (defaults to os setting)
# - `options`
#   - `noCreate` - don't create file if it already exists
#   - `time` - timw to set
#   - `mtime` - modification timw to set
#   - `reference` - use this file's time
#   - `noAccess` - (boolean) set access time
#   - `noModified` - (boolean) set modified time
# - `cb` - callback method
touch = module.exports.async = (file, options = {}, cb = ->) ->
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

touchSync = module.exports.sync = (file, options = {}) ->
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
