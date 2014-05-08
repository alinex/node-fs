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
  async.parallel [
    (cb) -> skipDepth depth, options, cb
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
  return false if skipTypeSync file, options
  return false if skipDepthSync depth, options
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
      return true unless file.match options.include
    else
      minimatch = require 'minimatch'
      return true unless minimatch file, options.include, { matchBase: true }
  if options.exclude
    if options.exclude instanceof RegExp
      return true if file.match options.exclude
    else
      minimatch = require 'minimatch'
      return true if minimatch file, options.exclude, { matchBase: true }
  return false

# ### Test the file depth
# The depth calculation has to be done in the traversing method this will only
# check the value against the options.
skipDepth = (depth, options, cb) ->
  cb skipDepthSync depth, options

skipDepthSync = (depth, options) ->
  return (options.mindepth? and options.mindepth > depth) or
    (options.maxdepth? and options.maxdepth < depth)

# ### Test the file type
skipType = (file, options, cb) ->
  return cb() unless options.type
  stat = if options.dereference? then fs.stat else fs.lstat
  stat file, (err, stats) ->
    return cb err if err
    switch options.type
      when 'file', 'f'
        return cb not stats.isFile()
      when 'directory', 'dir', 'd'
        return cb not stats.isDirectory()
      when 'link', 'l'
        return cb not stats.isSymbolicLink()
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
    when 'directory', 'dir', 'd'
      return not stats.isDirectory()
    when 'link', 'l'
      return not stats.isSymbolicLink()
    when 'fifo', 'pipe', 'p'
      return not stats.isFIFO()
    when 'socket', 's'
      return not stats.isSocket()
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
      stat = if options.dereference? then fs.stat else fs.lstat
      stat file, (err, stats) ->
        return cb err if err
    #    console.log file, uid, gid, stats.uid, stats.gid
        cb (uid and uid is not stats.uid) or (gid and gid is not stats.gid)

skipOwnerSync = (file, options) ->
  return false unless options.user or options.group
  uid = userToUidSync options.user
  gid = groupToGidSync options.group
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  stats = stat file
#  console.log file, uid, gid, stats.uid, stats.gid
  return (uid and uid is not stats.uid) or (gid and gid is not stats.gid)


# ### User provided test
# Here a function can be given which will be invoked and should return true
# if file can be used or false.
skipFunction = (file, options, cb) ->
  return cb() unless options.test or typeof options.test is not 'function'
  options.test file, options, (ok) ->
    cb not ok

skipFunctionSync = (file, options) ->
  return false unless options.test or typeof options.test is not 'function'
  return not options.test file, options

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
  stat = if options.dereference? then fs.stat else fs.lstat
  stat file, (err, stats) ->
    return cb err if err
#    console.log file, stats
    skip = not timeCheck stats, options
#    console.log file, skip
    cb skip

skipTimeSync = (file, options) ->
  used = false
  for type in ['accessed', 'modified', 'created']
    for dir in ['After', 'Before']
      used = true if options[type+dir]
  return false unless used
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  stats = stat file
  return not timeCheck stats, options
