# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
async = require 'async'
{execFile} = require 'child_process'
moment = require 'moment'

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
      return true if minimatch file, options.exclude, { matchBase: true }
  return false

# ### Test the filedepth
# The depth calculation has to be done in the traversing method this will only
# check the value against the options.
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
  skip

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
      ref = moment options[type+dir]
      console.log type, dir, ref
      unless ref.isValid()
        # try to read as duration
        ref = moment().subtract options[type+dir]
        unless ref.isValid()
          throw new Error "Given value '#{options[type+dir]}' in option #{type+dir} is invalid."
      value = moment stats[type.charAt(0) + type.slice(1) + 'time']
      return true if dir is 'Before' and value.isBefore ref
      return true if dir is 'After' and value.isAfter ref
  return false

skipTime = (file, options, cb) ->
  stat = if options.dereference? then fs.stat else fs.lstat
  stat source, (err, stats) ->
    return cb err if err
    cb not timeCheck stats, options

skipTimeSync = (file, options) ->
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  stats = stat file
  return not timeCheck stats, options
