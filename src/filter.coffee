# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
async = require 'async'
minimatch = require 'minimatch'

# Find files
# -------------------------------------------------
# This method will check a given file/path against some filter options.
#
# __Arguments:__
#
# * `file`
#   File to check against filter
# * `depth`
#   Search depth as integer (internal parameter).
# * `options`
#   Specification of files to success.
# * `callback(success)`
#   The callback will be called with a boolean value showing if file is accepted.
#
# The following options are available:
#
# - minmatch based
#   - `include` pattern
#   - `exclude` pattern
# - lstat based
#   - `ftype` string - type of entry like in lstat
#   - `atime` integer - accessed within last x seconds
#   - `mtime` integer - modified within last x seconds
#   - `ctime` integer - created within last x seconds
#   - `uid` integer - only files from this user
#   - `gid` integer - only files from this group
#   - `minsize` integer - file size in bytes
#   - `maxsize` integer - file size in bytes
module.exports.async = (file, depth, options = {}, cb = -> ) ->
  async.parallel [
    (cb) -> skipDepth depth, options, cb
    (cb) -> skipMinimatch file, options, cb
  ], (skip) ->
    cb not skip

# Find files (synchronous)
# -------------------------------------------------
# This method will check a given file/path against some filter options.
#
# __Arguments:__
#
# * `file`
#   File to check against filter
# * `depth`
#   Search depth as integer (internal parameter).
# * `options`
#   Specification of files to success.
#
# __Return:__
#
# * `success`
#   The callback will be called with a boolean value showing if file is accepted.
#
# The options are the same as in the asynchronous method.
module.exports.sync = (file, depth, options = {}) ->
  return false if skipDepthSync depth, options
  return false if skipMinimatchSync file, options
  true


# Skip Methods
# -------------------------------------------------
# The following methods will throw an boolean true as error if the file failed
# an specific test and therefore should not be included. If test is passed
# successfully it will return nothing.

skipMinimatch = (file, options, cb) ->
  return cb() unless options.include or options.exclude
  fs.lstat file, (err, stats) ->
    file += '/' if not err and stats.isDirectory()
    skip = false
    if options.include
      skip = not minimatch file, options.include,
        matchBase: true
    if options.exclude
      skip = minimatch file, options.exclude,
        matchBase: true
    # console.log "test #{file} +#{options.include} -#{options.exclude} skip=#{skip}"
    cb skip

skipMinimatchSync = (file, options) ->
  return false unless options.include or options.exclude
  try
    stats = fs.lstat file
  file += '/' if stats?.isDirectory()
  skip = false
  if options.include
    skip = not minimatch file, options.include,
      matchBase: true
  if options.exclude
    skip = minimatch file, options.exclude,
      matchBase: true
  # console.log "test #{file} +#{options.include} -#{options.exclude} skip=#{skip}"
  skip

skipDepth = (depth, options, cb) ->
  skip = (options.mindepth? > depth) or (options.mmaxdepth? < depth)
  cb skip

skipDepthSync = (depth, options) ->
  skip = (options.mindepth? > depth) or (options.mmaxdepth? < depth)


