# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
async = require 'async'
minimatch = require 'minimatch'
{execFile} = require 'child_process'

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
    (cb) -> skipType file, options, cb
    (cb) -> skipSize file, options, cb
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
  return false if skipTypeSync file, options
  return false if skipDepthSync depth, options
  return false if skipMinimatchSync file, options
  return false if skipSizeSync file, options
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
    stats = fs.lstatSync file
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
  cb skipDepthSync depth, options

skipDepthSync = (depth, options) ->
  return (options.mindepth? and options.mindepth > depth) or
    (options.maxdepth? and options.maxdepth < depth)

skipType = (file, options, cb) ->
  return cb() unless options.type
  stat = if options.dereference? then fs.stat else fs.lstat
  stat file, (err, stats) ->
    return cb err if err
    switch options.type
      when 'file', 'f'
        return cb not stats.isFile()
      when 'directory', 'd'
        return cb not stats.isDirectory()
      when 'link', 'l'
        return cb not stats.isSymbolikLink()
      when 'fifo', 'pipe', 'p'
        return cb not stats.isFIFO()
      when 'socket', 's'
        return cb not stats.isSocket()
    return cb true

skipTypeSync = (file, options) ->
  return false unless options.type
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  stats = stat file
  switch options.type
    when 'file', 'f'
      return not stats.isFile()
    when 'directory', 'd'
      return not stats.isDirectory()
    when 'link', 'l'
      return not stats.isSymbolikLink()
    when 'fifo', 'pipe', 'p'
      return not stats.isFIFO()
    when 'socket', 's'
      return not stats.isSocket()
  return true

sizeHumanToInt = (text) ->
  if match = text.match /^(\d*\.?\d*)\s*([kKmMgGtTpP])$/
  return switch match[2]
    when 'k', 'K' then match[1] * 1024
    when 'm', 'M' then match[1] * Math.pow 1024, 2
    when 'g', 'G' then match[1] * Math.pow 1024, 3
    when 'T', 'T' then match[1] * Math.pow 1024, 4
    when 'P', 'P' then match[1] * Math.pow 1024, 5

skipSize = (file, options, cb) ->
  return cb() unless options.minsize or options.maxsize
  options.minsize = sizeHumanToInt options.minsize if options.minsize
  options.maxsize = sizeHumanToInt options.maxsize if options.maxsize
  stat = if options.dereference? then fs.stat else fs.lstat
  stat file, (err, stats) ->
    return cb err if err
    skip = (options.minsize? and options.minsize > stats.size) or
      (options.maxsize? and options.maxsize < stats.size)
    cb skip

skipSizeSync = (file, options) ->
  return false unless options.minsize or options.maxsize
  options.minsize = sizeHumanToInt options.minsize if options.minsize
  options.maxsize = sizeHumanToInt options.maxsize if options.maxsize
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  stats = stat file
  return (options.minsize? and options.minsize > stats.size) or
    (options.maxsize? and options.maxsize < stats.size)

userToUid = (user, cb) ->
  return cb null, user unless isNaN user
  exec "id -u #{user}", (err, stdout, stderr) ->
    cb err, stdout.toString().trim()

userToUidSync = (user) ->
  return user unless isNaN user
  execSync "id -u #{user}", (err, stdout, stderr) ->
    cb err, stdout.toString().trim()
# use readfile /etc/passwd
# grep inline

groupToGid = (group, cb) ->
  return cb null, group unless isNaN group
  exec "grep ^#{group} /etc/group|cut -d: -f3", (err, stdout, stderr) ->
    cb err, stdout.toString().trim()

groupToGidSync = (group) ->
  return group unless isNaN group
  exec "grep ^#{group} /etc/group|cut -d: -f3", (err, stdout, stderr) ->
    cb err, stdout.toString().trim()
# use readfile /etc/group
# grep inline

skipOwner = (file, options, cb) ->
  return cb() unless options.user or options.group
  options.user = userToUid options.user if options.user
  options.group = groupToGid options.group if options.group
  stat = if options.dereference? then fs.stat else fs.lstat
  stat file, (err, stats) ->
    return cb err if err
    skip = (options.user? and options.user is not stats.uid) or
      (options.group? and options.group is not stats.gid)

skipOwnerSync = (file, options) ->
  return false unless options.user or options.group
  options.user = userToUidSync options.user if options.user
  options.group = groupToGidSync options.group if options.group
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  stats = stat file
  return (options.user? and options.user is not stats.uid) or
    (options.group? and options.group is not stats.gid)

###
  mode: 33188,
  nlink: 1,
  atime: Mon, 10 Oct 2011 23:24:11 GMT,
  mtime: Mon, 10 Oct 2011 23:24:11 GMT,
  ctime: Mon, 10 Oct 2011 23:24:11 GMT }
###
