###
Filter Check
=================================================
The filter is used to select some of the files based on specific settings.
The filter is given as options array which may have some of the following
specification settings.

But some methods may have special additional options not mentioned here.

- `include` - `Array|String` - to specify a inclusion pattern
- `exclude` to specify an exclusion pattern
- `dereference` set to true to follow symbolic links
- `ignoreErrors` set to true to forget errors and go on
- `mindepth` minimal depth to match
- `maxdepth` maximal depth to match
- `type` the inode type (file/directory/link)
- `test` own function to use
- `minsize` minimal filesize
- `maxsize` maximal filesize
- `user` owner name or id
- `group` owner group name or id
- `accessedAfter`
- `accessedBefore`
- `modifiedAfter`
- `modifiedBefore`
- `createdAfter`
- `createdBefore`

If you use multiple options all of them have to match the file to be valid.
See the details below.
###

# Node Modules
# -------------------------------------------------
fs = require 'fs'
path = require 'path'
async = require 'async'
chrono = require 'chrono-node'
debug = require('debug')('fs:filter')
util = require 'util'


# External Methods
# -------------------------------------------------

# @param {String} file to check against filter conditions
# @param {Integer} [depth=0] search depth for integer (internally used)
# @param {Object} [options] specifications for check defining which files to copy
# @param {function(<>Error>)} [cb] callback which is called after done with possible `Èrror`
module.exports.filter = (file, depth = 0, options = {}, cb = -> ) ->
  return cb true unless options? and Object.keys(options).length
  subpath = file.split /\//
#  subpath.shift() if subpath.length > 1
  subpath = subpath[subpath.length-depth..].join '/'
  skipPath (subpath ? file), options, (skip) ->
    if skip
      return cb() if skip is 'SKIPPATH'
      return cb false
    async.parallel [
      (cb) -> skipDepth file, depth, options, cb
      (cb) -> skipType file, options, cb
      (cb) -> skipSize file, options, cb
      (cb) -> skipTime file, options, cb
      (cb) -> skipOwner file, options, cb
      (cb) -> skipFunction file, options, cb
    ], (skip) ->
      cb not skip

# @param {String} file to check against filter conditions
# @param {Integer} [depth=0] search depth for integer (internally used)
# @param {Object} [options] specifications for check defining which files to copy
# @throws {Error} if anything out of order happened
module.exports.filterSync = (file, depth = 0, options = {}) ->
  return true unless options? and Object.keys(options).length
  debug "check #{file} for " + util.inspect options
  subpath = file.split /\//
#  subpath.shift() if subpath.length > 1
  subpath = subpath[subpath.length-depth..].join '/'
  if res = skipPathSync (subpath ? file), options
    return undefined if res is 'SKIPPATH'
    return false
  return false if skipTypeSync file, options
  return false if skipDepthSync file, depth, options
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

###
#3 File/path matching

This is based on glob expressions like used in unix systems. You may use these
as the `include` or `exclude` pattern while the `exclude` pattern has the higher
priority. All files are matched which are in the include pattern and not in the
exclude pattern.

The pattern may be a regular expression or a glob pattern string with
the following specification:

To use one of the special characters `*`, `?` or `[` you have to preceed it with an
backslash.

The patter may contain:

- `?` (not between brackets) matches any single character.
- `*` (not between brackets) matches any string, including the empty string.
- `**` (not between brackets) matches any string and also includes the path separator.

Character groups:

- `[ade]` or `[a-z]` Matches any one of the enclosed characters ranges can be given using a hyphen.
- `[!ade]` or `[!a-z]` negates the search and matches any character not enclosed.
- `[^ade]` or `[^a-z]` negates the search and matches any character not enclosed.

Brace Expansion:

- `{a,b}` will be expanded to `a` or `b`
- `{a,b{c,d}}` stacked to match `a`, `bc` or `bd`
- `{1..3}` will be expanded to `1` or `2` or `3`

Extended globbing is also possible:

- ?(list): Matches zero or one occurrence of the given patterns.
- *(list): Matches zero or more occurrences of the given patterns.
- +(list): Matches one or more occurrences of the given patterns.
- @(list): Matches one of the given patterns.
###

# ### Test the path
# This is done using Minimatch or RegExp
skipPath = (file, options, cb) ->
  cb skipPathSync file, options

skipPathSync = (file, options) ->
  return false unless options.include or options.exclude
  if options.include
    if options.include instanceof RegExp
      unless file.match options.include
        debug "skip #{file} because path not included (regexp)"
        return true
    else if options.include isnt path.basename file
      minimatch = require 'minimatch'
      unless minimatch file, options.include, {matchBase: true}
        debug "skip #{file} because path not included (glob)"
        return true
  if options.exclude
    if options.exclude instanceof RegExp
      if file.match options.exclude
        debug "skip #{file} because path excluded (regexp)"
        return 'SKIPPATH'
    else if options.exclude is path.basename file
      return true
    else
      minimatch = require 'minimatch'
      if minimatch file, options.exclude, {matchBase: true}
        debug "skip #{file} because path excluded (glob)"
        return 'SKIPPATH'
  return false


###
#3 Search depth

The search depth specifies in which level of subdirectories the filter will match.
1 means everything in the given directory, 2 one level deeper.

- `mindepth` minimal depth to match
- `maxdepth` maximal depth to match


#3 File type

Use `type` to specify which type of file you want to use.

Possible values:

- `file`, `f`
- `directory`, `dir`, `d`
- `link`, `l`
- `fifo`, `pipe`, `p`
- `socket`, `s`
###


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

###
#3 File size

With the `minsize` and  `maxsize` options it is possible to specify the exact
size of the matching files in bytes:

- use an integer value as number of bytes
- use a string like `1M` or `100k`
###

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
  catch error
    debug "error resolving #{file} link #{error.message}"
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

###
#3 Owner and Group

You may also specify files based on the user which owns the files or the group
of the files.

Both may be specified as id (uid or gid) or using the alias name.
###

# ### Check the owwner and group
userToUid = (user, cb) ->
  return cb null, user unless user and not isNaN user
  fs.readFile '/etc/passwd', {encoding: 'utf-8'}, (err, data) ->
    return cb err if err
    for line in data.split /\n/
      cols = line.split /:/
      return cb null, cols[2] if cols[0] is user
    fs.stat '/Users/'+user, (err, stats) ->
      return cb user if err
      cb null, stats.uid

userToUidSync = (user) ->
  return user unless user and not isNaN user
  data = fs.readFileSync '/etc/passwd', {encoding: 'utf-8'}
  for line in data.split /\n/
    cols = line.split /:/
    return cols[2] if cols[0] is user
  try
    stats = fs.statSync '/Users/'+user
  return stats.uid

groupToGid = (group, cb) ->
  return cb null, group unless group and not isNaN group
  fs.readFile '/etc/group', {encoding: 'utf-8'}, (err, data) ->
    return cb err if err
    for line in data.split /\n/
      cols = line.split /:/
      return cb null, cols[2] if cols[0] is group
    cb()

groupToGidSync = (group) ->
  return group unless group and not isNaN group
  data = fs.readFileSync '/etc/group', {encoding: 'utf-8'}
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

###
#3 Time specification

It is also possible to select files based on their `creation`, last `modified`
or last `accessed` time.

Specify the `Before` and `After` time appended to one of the above as:

- Unix timestamp
- ISO-8601 date formats
- some local formats (based on platform support for Date.parse())
- time difference from now (human readable)

The following time definitions are an example what you may use:

- `yesterday`, `2 days ago`, `last Monday` to specify a day from now
- `yesterday 15:00`, `yesterday at 15:00` to also specify the time
- `1 March`, `1st March` specifies a date in this year
- `1 March 2014`, `1st March 2014`, '03/01/13`, `01.03.2014` all specifiying the 1st of march
- `9:00`, `9:00 GMT+0900` to specify a time today or in combination with a date
- `last night`, `00:00`

If only a day is given it will use 12:00 as the time.

__Examle__

    modifiedBefore: 'yesterday 12:00'

###

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

###
#3 User defined function

With the `test` parameter you may add an user defined function which will be
called to check each file. It will get the file path and options array so you
may also add some configuration therefore in additional option values.

Asynchrony call:

``` coffee
fs.find('.', {
  test: function(file, options, cb) {
    cb(~file.indexOf('ab'));
  }
}, function(err, list) {
  console.log("Found " + list.length + " matches.");
});
```

Or use synchrony calls:

``` coffee
var list = fs.findSync('test/temp', {
  test: function(fil, options) {
    return ~file.indexOf('ab');
  }
});
console.log("Found " + list.length + " matches.");
```
###

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