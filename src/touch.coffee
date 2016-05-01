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
#   - `access` - (boolean) set access time
#   - `modified` - (boolean) set modified time
# - `cb` - callback method
touch = module.exports.async = (file, options = {}, cb = ->) ->
  # optional arguments
  atime = mtime = options.time
  mtime = options.mtime if options.mtime
  if options.reference
    return fs.stat options.reference, (err, stats) ->
      return cb err if err
      {atime, mtime} = stats
      touch file,
        time: atime
        mtime: mtime
        noCreate: options.noCreate
      , cb
  atime = null if options.access or not options.access?
  mtime = null if options.modified or not options.modified?
  # do the touch
  fs.exists file, (exists) ->
    return cb() if exists and options.noCreate
    fs.open file, 'a', (err, fd) ->
      return cb err if err
      fs.close fd, (err) ->
        return cb err if err
        fs.utimes file, atime, mtime, cb

touchSync = module.exports.sync = (file, options = {}) ->
  # optional arguments
  atime = mtime = options.time
  mtime = options.mtime if options.mtime
  if options.reference
    {atime, mtime} = fs.statSync options.reference
    return touchSync file,
      time: atime
      mtime: mtime
      noCreate: options.noCreate
  atime = null if options.access or not options.access?
  mtime = null if options.modified or not options.modified?
  # do the touch
  return if fs.existsSync(file) and options.noCreate
  fs.closeSync fs.openSync file, 'a'
  fs.utimesSync file, atime, mtime
