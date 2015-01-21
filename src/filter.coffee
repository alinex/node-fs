# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
async = require 'async'
{execFile} = require 'child_process'
chrono = require 'chrono-node'
debug = require('debug')('fs:filter')
util = require 'util'

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
module.exports.async = (file, depth, options = {}, cb = -> ) ->
  return cb true unless options? and Object.keys(options).length
  debug "check #{file} for " + util.inspect options
  async.parallel [
    (cb) -> skipDepth file, depth, options, cb
    (cb) -> skipPath file, options, cb
    (cb) -> skipType file, options, cb
    (cb) -> skipSize file, options, cb
    (cb) -> skipTime file, options, cb
    (cb) -> skipOwner file, options, cb
    (cb) -> skipFunction file, options, cb
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
  return true unless options? and Object.keys(options).length
  debug "check #{file} for " + util.inspect options
  return false if skipTypeSync file, options
  return false if skipDepthSync file, depth, options
  return false if skipPathSync file, options
  return false if skipSizeSync file, options
  return false if skipTimeSync file, options
  return false if skipOwnerSync file, options
  return false if skipFunctionSync file, options
  true


# Skip Methods
# -------------------------------------------------
# The following methods will throw/return an boolean true as error if the file
# failed an specific test and therefore should not be included. If test is passed
# successfully it will return nothing.

# ### Test the path
# This is done using Minimatch or RegExp
skipPath = (file, options, cb) ->
  cb skipPathSync file, options

skipPathSync = (file, options) ->
  return false unless options.include or options.exclude
  if options.include
    if options.include instanceof RegExp
      unless file.match options.include
        debug "skip #{file} because path not included"
        return true
    else
      minimatch = require 'minimatch'
      unless minimatch file, options.include, { matchBase: true }
        debug "skip #{file} because path not included"
        return true
  if options.exclude
    if options.exclude instanceof RegExp
      if file.match options.exclude
        debug "skip #{file} because path excluded"
        return true
    else
      minimatch = require 'minimatch'
      if minimatch file, options.exclude, { matchBase: true }
        debug "skip #{file} because path excluded"
        return true
  return false

# ### Test the file depth
# The depth calculation has to be done in the traversing method this will only
# check the value against the options.
skipDepth = (file, depth, options, cb) ->
  cb skipDepthSync file, depth, options

skipDepthSync = (file, depth, options) ->
  skip = (options.mindepth? and options.mindepth > depth) or
    (options.maxdepth? and options.maxdepth < depth)
  debug "skip #{file} because not in specified depth" if skip
  return skip

filestat = (file, options, cb) ->
  stat = if options.dereference? then fs.stat else fs.lstat
  stat file, (err, stats) ->
    if err and options.dereference?
      debug "error resolving #{file} link"
      return filestat file, {}, cb
    cb err, stats

filestatSync = (file, options) ->
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  try
    return stat file
  catch err
    debug "error resolving #{file} link"
    return filestatSync file, {}

# ### Test the file type
skipType = (file, options, cb) ->
  return cb() unless options.type
  filestat file, options, (err, stats) ->
    if err
      debug "skip because error #{err} in stat for #{file}"
      return cb()
    switch options.type
      when 'file', 'f'
        return cb() if stats.isFile()
        debug "skip #{file} because not a file entry"
      when 'directory', 'dir', 'd'
        return cb() if stats.isDirectory()
        debug "skip #{file} because not a directory entry"
      when 'link', 'l'
        return cb() if stats.isSymbolicLink()
        debug "skip #{file} because not a link entry"
      when 'fifo', 'pipe', 'p'
        return cb() if stats.isFIFO()
        debug "skip #{file} because not a FIFO entry"
      when 'socket', 's'
        return cb() if stats.isSocket()
        debug "skip #{file} because not a socket entry"
    return cb true

skipTypeSync = (file, options) ->
  return false unless options.type
  try
    stats = filestatSync file, options
  catch err
    debug "skip because error #{err} in stat for #{file}"
    return
  switch options.type
    when 'file', 'f'
      return if stats.isFile()
      debug "skip #{file} because not a file entry"
    when 'directory', 'dir', 'd'
      return if stats.isDirectory()
      debug "skip #{file} because not a directory entry"
    when 'link', 'l'
      return if stats.isSymbolicLink()
      debug "skip #{file} because not a link entry"
    when 'fifo', 'pipe', 'p'
      return if stats.isFIFO()
      debug "skip #{file} because not a FIFO entry"
    when 'socket', 's'
      return if stats.isSocket()
      debug "skip #{file} because not a socket entry"
  return true

# ### Test for filesize
sizeHumanToInt = (text) ->
  if typeof text is 'string' and match = text.match /^(\d*\.?\d*)\s*([kKmMgGtTpP])$/
    return switch match[2]
      when 'k', 'K' then match[1] * 1024
      when 'm', 'M' then match[1] * Math.pow 1024, 2
      when 'g', 'G' then match[1] * Math.pow 1024, 3
      when 'T', 'T' then match[1] * Math.pow 1024, 4
      when 'P', 'P' then match[1] * Math.pow 1024, 5
  text

skipSize = (file, options, cb) ->
  return cb() unless options.minsize or options.maxsize
  options.minsize = sizeHumanToInt options.minsize if options.minsize
  options.maxsize = sizeHumanToInt options.maxsize if options.maxsize
  filestat file, options, (err, stats) ->
    if err
      debug "skip because error #{err} in stat for #{file}"
      return cb()
    skip = (options.minsize? and options.minsize > stats.size) or
      (options.maxsize? and options.maxsize < stats.size)
    debug "skip #{file} because size mismatch" if skip
    cb skip

skipSizeSync = (file, options) ->
  return false unless options.minsize or options.maxsize
  options.minsize = sizeHumanToInt options.minsize if options.minsize
  options.maxsize = sizeHumanToInt options.maxsize if options.maxsize
  try
    stats = filestatSync file, options
  catch err
    debug "skip because error #{err} in stat for #{file}"
    return
  skip = (options.minsize? and options.minsize > stats.size) or
    (options.maxsize? and options.maxsize < stats.size)
  debug "skip #{file} because size mismatch" if skip
  return skip

# ### Check the owwner and group
userToUid = (user, cb) ->
  return cb null, user unless user and not isNaN user
  fs.readFile '/etc/passwd', { encoding: 'utf-8' }, (err, data) ->
    return cb err if err
    for line in data.split /\n/
      cols = line.split /:/
      return cb null, cols[2] if cols[0] is user
    fs.stat '/Users/'+user, (err, stats) ->
      return cb user if err
      cb null, stats.uid

userToUidSync = (user) ->
  return user unless user and not isNaN user
  data = fs.readFileSync '/etc/passwd', { encoding: 'utf-8' }
  for line in data.split /\n/
    cols = line.split /:/
    return cols[2] if cols[0] is user
  try
    stats = fs.statSync '/Users/'+user
  return stats.uid

groupToGid = (group, cb) ->
  return cb null, group unless group and not isNaN group
  fs.readFile '/etc/group', { encoding: 'utf-8' }, (err, data) ->
    return cb err if err
    for line in data.split /\n/
      cols = line.split /:/
      return cb null, cols[2] if cols[0] is group
    cb()

groupToGidSync = (group) ->
  return group unless group and not isNaN group
  data = fs.readFileSync '/etc/group', { encoding: 'utf-8' }
  for line in data.split /\n/
    cols = line.split /:/
    return cols[2] if cols[0] is group
  return group

skipOwner = (file, options, cb) ->
  return cb() unless options.user or options.group
  userToUid options.user, (err, uid) ->
    return cb err if err
    groupToGid options.group, (err, gid) ->
      return cb err if err
      filestat file, options, (err, stats) ->
        if err
          debug "skip because error #{err} in stat for #{file}"
          return cb()
        skip = (uid and uid is not stats.uid) or (gid and gid is not stats.gid)
        debug "skip #{file} because owner mismatch" if skip
        cb skip

skipOwnerSync = (file, options) ->
  return false unless options.user or options.group
  uid = userToUidSync options.user
  gid = groupToGidSync options.group
  try
    stats = filestatSync file, options
  catch err
    debug "skip because error #{err} in stat for #{file}"
    return
#  console.log file, uid, gid, stats.uid, stats.gid
  skip = (uid and uid is not stats.uid) or (gid and gid is not stats.gid)
  debug "skip #{file} because owner mismatch" if skip
  return skip


# ### User provided test
# Here a function can be given which will be invoked and should return true
# if file can be used or false.
skipFunction = (file, options, cb) ->
  return cb() unless options.test or typeof options.test is not 'function'
  options.test file, options, (ok) ->
    debug "skip #{file} by user function" unless ok
    cb not ok

skipFunctionSync = (file, options) ->
  return false unless options.test or typeof options.test is not 'function'
  ok = options.test file, options
  debug "skip #{file} by user function" unless ok
  return not ok

# ### Check file times
# All timestamps maybe checked with before and after to select the files.
#
# This may be enhanced later using date.js for human readable date specifications.
timeCheck = (stats, options) ->
  for type in ['accessed', 'modified', 'created']
    for dir in ['After', 'Before']
      continue unless options[type+dir]
      # try to read as specific date
      ref = options[type+dir]
      ref = chrono.parseDate(ref)?.getTime()/1000 if typeof ref is 'string'
      unless ref
        throw new Error "Given value '#{options[type+dir]}' in option #{type+dir} is invalid."
      value = stats[type.charAt(0) + 'time'].getTime()/1000
#      console.log type, dir, options[type+dir], value, ref
      return false if dir is 'Before' and value >= ref
      return false if dir is 'After' and value <= ref
  return true

skipTime = (file, options, cb) ->
  used = false
  for type in ['accessed', 'modified', 'created']
    for dir in ['After', 'Before']
      used = true if options[type+dir]
  return cb false unless used
  filestat file, options, (err, stats) ->
    if err
      debug "skip because error #{err} in stat for #{file}"
      return cb()
#    console.log file, stats
    skip = not timeCheck stats, options
#    console.log file, skip
    debug "skip #{file} because out of time range" if skip
    cb skip

skipTimeSync = (file, options) ->
  used = false
  for type in ['accessed', 'modified', 'created']
    for dir in ['After', 'Before']
      used = true if options[type+dir]
  return false unless used
  try
    stats = filestatSync file, options
  catch err
    debug "skip because error #{err} in stat for #{file}"
    return
  skip = not timeCheck stats, options
  debug "skip #{file} because out of time range" if skip
  return skip