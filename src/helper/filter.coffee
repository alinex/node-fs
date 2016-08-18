###
Filter Rules
=================================================
The filter is used to select some of the files based on specific settings.
You can't call the filter directly but it is used from most methods for file selection.

#4 Options

The filter definition is given as options array which may have some of the following
specification settings. But some methods may have special additional options not mentioned here.

The filter is given as `filter` element in the options object and be specified as subobject
or list of objects with these settings:
- `include` - `Array<String|RegExp>|String|RegExp` to specify a inclusion pattern
- `exclude` - `Array<String|RegExp>|String|RegExp` to specify an exclusion pattern
- `mindepth` - `Integer` minimal depth to match
- `maxdepth` - `Integer` maximal depth to match
- `dereference` - `Boolean` set to true to follow symbolic links
- `type` - `String` the inode type it should be one of:
  - `file`, `f`
  - `directory`, `dir`, `d`
  - `link`, `l`
  - `fifo`, `pipe`, `p`
  - `socket`, `s`
- `minsize` - `Integer|String` minimal filesize
- `maxsize` - `Integer|String` maximal filesize
- `user` - `Integer|String` owner name or id
- `group` - `Integer|String` owner group name or id
- `accessedAfter` - `Integer|String` last access time should be after that value
- `accessedBefore` - `Integer|String` last access time should be before that value
- `modifiedAfter` - `Integer|String` last modified time should be after that value
- `modifiedBefore` - `Integer|String` last modified time should be before that value
- `createdAfter` - `Integer|String` creation time should be after that value
- `createdBefore` - `Integer|String` creation time should be before that value
- `test` - `Function` own function to use

If you use multiple options all of them have to match the file to be valid.
See the details below.

#4 Multiple Option Sets

Multiple sets of the above rules can also be given as list of option arrays. If so
all files are allowed, which match any of the given option sets.
###


# Node Modules
# -------------------------------------------------
debug = require('debug')('fs:filter')
fs = require 'fs'
path = require 'path'
async = require 'async'
chrono = require 'chrono-node'
util = require 'util'
posix = require 'posix'


# External Methods
# -------------------------------------------------
# ::: warning Changed Parameters
# The meaning of the return values from the {@link find()} and {@link findSync()}
# methods are the opposite of the `skip...()` methods. Because `skip...()` will
# return `true` if this should not be used and `filter...()` will return `true`
# if the file should be kept and not filtered out.
#
# Also the options of the skip method are
# :::

# Check if the given file is ok or should be filtered out.
#
# @param {String} file to check against filter conditions
# @param {Integer} [depth=0] search depth for integer (internally used)
# @param {Array<Object>|Object} [options] specifications for check defining which
# files to use like defined above
# @param {function(<Boolean>)} [cb] callback if decided with
# - `true` if ok and can be used
# - `false` if element should not be used
# - `undefined` to also stop going into subdirectories
module.exports.filter = (file, depth = 0, options = {}, cb = -> ) ->
  return cb true unless options?.filter?
  list = if Array.isArray options.filter then options.filter else [options.filter]
  subpath = file.split /\//
  subpath = subpath[subpath.length-depth..].join '/'
  subpath = null unless subpath.length
  async.map list, (options, cb) ->
    return cb true unless Object.keys(options).length
    skipPath (subpath ? file), options, (skip) ->
      if skip
        return cb skip if skip is 'SKIPPATH'
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
  , (err) ->
    if err is 'SKIPPATH'
      debug "#{file} SKIPPATH"
      return cb()
    debug "#{file} #{if err then 'OK' else 'SKIP'}"
    cb if err then true else false

# Check if the given file is ok or should be filtered out.
#
# @param {String} file to check against filter conditions
# @param {Integer} [depth=0] search depth for integer (internally used)
# @param {Array<Object>|Object} [options] specifications for check defining which
# files to use like defined above
# @return {Boolean} flag if decided with
# - `true` if ok and can be used
# - `false` if element should not be used
# - `undefined` to also stop going into subdirectories
module.exports.filterSync = (file, depth = 0, options) ->
  return true unless options?.filter?
  list = if Array.isArray options.filter then options.filter else [options.filter]
  subpath = file.split /\//
  subpath = subpath[subpath.length-depth..].join '/'
  subpath = null unless subpath.length
  for options in list
    return true unless Object.keys(options).length
    debug "check #{file} for " + util.inspect options
    if res = skipPathSync (subpath ? file), options
      if res is 'SKIPPATH'
        debug "#{file} SKIP"
        return undefined
      continue
    continue if skipTypeSync file, options
    continue if skipDepthSync file, depth, options
    continue if skipSizeSync file, options
    continue if skipTimeSync file, options
    continue if skipOwnerSync file, options
    continue if skipFunctionSync file, options
    debug "#{file} OK"
    return true
  debug "#{file} SKIP"
  false


# Skip Methods
# -------------------------------------------------
# The following methods will throw/return an boolean true as error if the file
# failed an specific test and therefore should not be included. If test is passed
# successfully it will return nothing.

###
#3 File/Path Matching

This is based on glob expressions like used in unix systems. You may use these
as the `include` or `exclude` pattern while the `exclude` pattern has the higher
priority. All files are matched which are in the include pattern and not in the
exclude pattern.

Both patterns may also be given as `Array` to match multiple. If multiple are given
they are combined logically using OR meaning that at least one include have to match
and no exclude should match.

__Regular expressions__

The pattern may be a regular expression given as String. See {@link RegExp()}
for the format description.

__Pattern Matching__

Alternatively you may use glob pattern string with the following specification:

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

See more information about pattern matching in {@link minimatch}.

__Example__

``` coffee
fs = require 'alinex-fs'
fs.find '/tmp/some/directory',
  filter:
    include: 'a*'
    exclude: '*c'
, (err, list) ->
  # list may include 'a', 'abd', 'abe'
  # but not 'abc'
```
###

# This is done using Minimatch or RegExp.
#
# @param {String} file with full path
# @param {Object} options specification of check
# - `include` - `Array<String|RegExp>|String|RegExp` to specify a inclusion pattern
# - `exclude` - `Array<String|RegExp>|String|RegExp` to specify an exclusion pattern
# @param {function(<Boolean>|<String>)} cb callback with
# - `true` if element should not be used
# - `false` if ok and can be used
# - `SKIPPATH` to also stop going into subdirectories
# @see {@link skipPathSync()} for description
skipPath = (file, options, cb) ->
  cb skipPathSync file, options

# This is done using Minimatch or RegExp.
#
# @param {String} file with full path
# @param {Object} options specification of check
# - `include` - `Array<String|RegExp>|String|RegExp` to specify a inclusion pattern
# - `exclude` - `Array<String|RegExp>|String|RegExp` to specify an exclusion pattern
# @return {Boolean|String} result may be
# - `true` if element should not be used
# - `false` if ok and can be used
# - `SKIPPATH` to also stop going into subdirectories
# @see {@link skipPath()} for description
skipPathSync = (file, options) ->
  return false unless options.include or options.exclude
  if options.exclude
    list = if Array.isArray options.exclude then options.exclude else [options.exclude]
    for exclude in list
      if exclude instanceof RegExp
        if file.match exclude
          debug "skip #{file} because path excluded (regexp)"
          return 'SKIPPATH'
      else if exclude is path.basename file
        return true
      else
        minimatch = require 'minimatch'
        if minimatch file, exclude, {matchBase: true}
          debug "skip #{file} because path excluded (glob)"
          return 'SKIPPATH'
  if options.include
    list = if Array.isArray options.include then options.include else [options.include]
    ok = false
    for include in list
      if include instanceof RegExp
        if file.match include
          ok = true
          break
      else if include isnt path.basename file
        minimatch = require 'minimatch'
        if minimatch file, include, {matchBase: true}
          ok = true
          break
      else
        ok = true
        break
    unless ok
      debug "skip #{file} because path not included"
      return true
  return false


###
#3 Search depth

The search depth specifies in which level of subdirectories the filter will match.
1 means everything in the given directory, 2 one level deeper.
- `mindepth` - `Integer` minimal depth to match
- `maxdepth` - `Integer` maximal depth to match

__Example__

``` coffee
fs = require 'alinex-fs'
fs.find '/tmp/some/directory',
  filter:
    mindepth: 1
    maxdepth: 1
, (err, list) ->
  # only the first sublevele:
  # list may include 'dir1/abc', 'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
```
###

# The depth calculation has to be done in the traversing method this will only
# check the value against the options.
#
# @param {String} file with full path
# @param {Object} options specification of check
# - `mindepth` - `Integer` minimal depth to match
# - `maxdepth` - `Integer` maximal depth to match
# @param {function(<Boolean>|<String>)} cb callback with
# - `true` if element should not be used
# - `false` if ok and can be used
# - `SKIPPATH` to also stop going into subdirectories
# @see {@link skipDepthSync()} for description
skipDepth = (file, depth, options, cb) ->
  cb skipDepthSync file, depth, options

# The depth calculation has to be done in the traversing method this will only
# check the value against the options.
#
# @param {String} file with full path
# @param {Object} options specification of check
# - `mindepth` - `Integer` minimal depth to match
# - `maxdepth` - `Integer` maximal depth to match
# @return {Boolean|String} with possible value
# - `true` if element should not be used
# - `false` if ok and can be used
# - `SKIPPATH` to also stop going into subdirectories
# @see {@link skipDepth()} for description
skipDepthSync = (file, depth, options) ->
  if options.maxdepth? and options.maxdepth < depth
    debug "skip #{file} because deeper than specified depth"
    return 'SKIPPATH'
  if options.mindepth? and options.mindepth > depth
    debug "skip #{file} because not in specified depth"
    return true
  return false

# @param {String} file with full path
# @param {Object} options specification of check
# - `dereference` - `Boolean` set to true to follow symbolic links
# @üaram {function(<Error>, <fs.Stats>)} cb the callback with `Èrror` or the
# {@link fs.Stats} information
# @see used in {@link skipType()}
# @description If dereferencing failed it will automazically anaöyse the link itself.
filestat = (file, options, cb) ->
  stat = if options.dereference? then fs.stat else fs.lstat
  stat file, (err, stats) ->
    if err and options.dereference?
      debug "error resolving #{file} link"
      return filestat file, {}, cb
    cb err, stats

# @param {String} file with full path
# @param {Object} options specification of check
# - `dereference` - `Boolean` set to true to follow symbolic links
# @return {fs.Stats} {@link fs.Stats} information
# @throw {Error} if a problem occured
# @see used in {@link skipTypeSync()}
# @description If dereferencing failed it will automazically anaöyse the link itself.
filestatSync = (file, options) ->
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  try
    return stat file
  catch error
    debug "error resolving #{file} link #{error.message}"
    return filestatSync file, {} if options.dereference?
    throw error

###
#3 File type

Use `type` to specify which type of file you want to use.

Possible values:

- `file`, `f`
- `directory`, `dir`, `d`
- `link`, `l`
- `fifo`, `pipe`, `p`
- `socket`, `s`

Also you may set `dereference` to `true` to follow symbolic links and analyze their
target.

__Example__

``` coffee
fs = require 'alinex-fs'
fs.find '/tmp/some/directory',
  filter:
    type: 'f'
, (err, list) ->
  # list may include 'test/temp/file1', 'test/temp/file2', 'test/temp/dir1/file11'
```
###

# Check the type of the inode.
#
# @param {String} file with full path
# @param {Object} options specification of check
# - `type` - `String` the inode type it should be one of:
#   - `file`, `f`
#   - `directory`, `dir`, `d`
#   - `link`, `l`
#   - `fifo`, `pipe`, `p`
#   - `socket`, `s`
# @param {function(<Boolean>)} cb callback with
# - `true` if element should not be used
# - `false` if ok and can be used
# @see {@link skipTypeSync()} for description
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

# Check the type of the inode.
#
# @param {String} file with full path
# @param {Object} options specification of check
# - `type` - `String` the inode type it should be one of:
#   - `file`, `f`
#   - `directory`, `dir`, `d`
#   - `link`, `l`
#   - `fifo`, `pipe`, `p`
#   - `socket`, `s`
# @return {Boolean} with
# - `true` if element should not be used
# - `false` if ok and can be used
# @see {@link skipType()} for description
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

# Transform human size format to binary value.
#
# @param {String} text human format of file size
# @return {Integer} number of bytes
sizeHumanToInt = (text) ->
  if typeof text is 'string' and match = text.match /^(\d*\.?\d*)\s*([kKmMgGtTpP])$/
    return switch match[2]
      when 'k', 'K' then match[1] * 1024
      when 'm', 'M' then match[1] * Math.pow 1024, 2
      when 'g', 'G' then match[1] * Math.pow 1024, 3
      when 'T', 'T' then match[1] * Math.pow 1024, 4
      when 'P', 'P' then match[1] * Math.pow 1024, 5
  text

###
#3 File size

With the `minsize` and  `maxsize` options it is possible to specify the exact
size of the matching files in bytes:

- use an `Integer` value as number of bytes
- use a `String` like `1M` or `100k`

__Example__

``` coffee
fs = require 'alinex-fs'
fs.find '/tmp/some/directory',
  filter:
    maxsize: 1024 * 1024
, (err, list) ->
  # list contains only files larger than 1MB
```
###

# Check the type of the inode.
#
# @param {String} file with full path
# @param {Object} options specification of check
# - `minsize` - `Integer|String` minimal filesize
# - `maxsize` - `Integer|String` maximal filesize
# @param {function(<Boolean>)} cb callback with
# - `true` if element should not be used
# - `false` if ok and can be used
# @see {@link skipSizeSync()} for description
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

# Check the type of the inode.
#
# @param {String} file with full path
# @param {Object} options specification of check
# - `minsize` - `Integer|String` minimal filesize
# - `maxsize` - `Integer|String` maximal filesize
# @return {Boolean} one of
# - `true` if element should not be used
# - `false` if ok and can be used
# @see {@link skipSize()} for description
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
- `user` - `Integer|String` owner name or id
- `group` - `Integer|String` owner group name or id

__Example__

``` coffee
fs = require 'alinex-fs'
fs.find '/tmp/some/directory',
  filter:
    user: process.uid
, (err, list) ->
  # list contains only files belonging to the current user
```
###

# @param {String} file with full path
# @param {Object} options specification of check
# - `user` - `Integer|String` owner name or id
# - `group` - `Integer|String` owner group name or id
# @param {function(<Boolean>)} cb callback with
# - `true` if element should not be used
# - `false` if ok and can be used
# @see {@link skipOwnerSync()} for description
skipOwner = (file, options, cb) ->
  return cb() unless options.user or options.group
  # user/group string to id
  if options.user and not isNaN options.user
    try
      uid = posix.getpwnam(options.user).uid
    catch error
      return cb error
  if options.group and not isNaN options.group
    try
      gid = posix.getgrnam(options.group).gid
    catch error
      return cb error
  # run check
  filestat file, options, (err, stats) ->
    if err
      return cb err if err
      debug "skip because error #{err} in stat for #{file}"
      return cb()
    skip = (uid and uid is not stats.uid) or (gid and gid is not stats.gid)
    debug "skip #{file} because owner mismatch" if skip
    cb skip

# @param {String} file with full path
# @param {Object} options specification of check
# - `user` - `Integer|String` owner name or id
# - `group` - `Integer|String` owner group name or id
# @return {Boolean} one of
# - `true` if element should not be used
# - `false` if ok and can be used
# @see {@link skipOwner()} for description
skipOwnerSync = (file, options) ->
  return false unless options.user or options.group
  # user/group string to id
  if options.user and not isNaN options.user
    uid = posix.getpwnam(options.user).uid
  if options.group and not isNaN options.group
    gid = posix.getgrnam(options.group).gid
  # run check
  try
    stats = filestatSync file, options
  catch err
    debug "skip because error #{err} in stat for #{file}"
    throw err
  skip = (uid and uid is not stats.uid) or (gid and gid is not stats.gid)
  debug "skip #{file} because owner mismatch" if skip
  return skip

# Check the different file times.
#
# @param {fs.Stats} stats
# @param {Object} options
# @return {Boolean} one of
# - `true` if element should not be used
# - `false` if ok and can be used
# @throw {Error} Given value ... in option ... is invalid.
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
      return false if dir is 'Before' and value >= ref
      return false if dir is 'After' and value <= ref
  return true

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

__Example__

``` coffee
fs = require 'alinex-fs'
fs.find '/tmp/some/directory',
  filter:
    modifiedBefore: 'yesterday 12:00'
, (err, list) ->
  # list contains only files older than yesterday 12 o'clock
```
###

# @param {String} file with full path
# @param {Object} options specification of check
# - `accessedAfter` - `Integer|String` last access time should be after that value
# - `accessedBefore` - `Integer|String` last access time should be before that value
# - `modifiedAfter` - `Integer|String` last modified time should be after that value
# - `modifiedBefore` - `Integer|String` last modified time should be before that value
# - `createdAfter` - `Integer|String` creation time should be after that value
# - `createdBefore` - `Integer|String` creation time should be before that value
# @param {function(<Boolean>)} cb callback with
# - `true` if element should not be used
# - `false` if ok and can be used
# @see {@link skipOwnerSync()} for description
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
    skip = not timeCheck stats, options
    debug "skip #{file} because out of time range" if skip
    cb skip

# @param {String} file with full path
# @param {Object} options specification of check
# - `accessedAfter` - `Integer|String` last access time should be after that value
# - `accessedBefore` - `Integer|String` last access time should be before that value
# - `modifiedAfter` - `Integer|String` last modified time should be after that value
# - `modifiedBefore` - `Integer|String` last modified time should be before that value
# - `createdAfter` - `Integer|String` creation time should be after that value
# - `createdBefore` - `Integer|String` creation time should be before that value
# @return {Boolean} one of
# - `true` if element should not be used
# - `false` if ok and can be used
# @see {@link skipTime()} for description
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

Asynchronous call:

``` coffee
fs = require 'alinex-fs'
fs.find '.',
  filter:
    test: (file, options, cb) ->
      cb ~file.indexOf 'ab'
, (err, list) ->
  console.log "Found #{list.length} matches."
```

Or use synchronous calls:

``` coffee
fs = require 'alinex-fs'
list = fs.findSync 'test/temp',
  filter:
    test: (file, options) ->
      return ~file.indexOf 'ab'
console.log "Found #{list.length} matches."
```
###

# Here a function can be given which will be invoked and should return true
# if file can be used or false.
#
# @param {String} file with full path
# @param {Object} options specification of check
# - `test` - `Function` with same interface as this one
# @param {function(<Boolean>)} cb callback with
# - `true` if element should not be used
# - `false` if ok and can be used
# @see {@link skipFunctionSync()} for description
skipFunction = (file, options, cb) ->
  return cb() unless options.test or typeof options.test is not 'function'
  options.test file, options, (ok) ->
    debug "skip #{file} by user function" unless ok
    cb not ok

# @param {String} file with full path
# @param {Object} options specification of check
# - `test` - `Function` with same interface as this one
# @return {Boolean} one of
# - `true` if element should not be used
# - `false` if ok and can be used
# @see {@link skipFunction()} for description
skipFunctionSync = (file, options) ->
  return false unless options.test or typeof options.test is not 'function'
  ok = options.test file, options
  debug "skip #{file} by user function" unless ok
  return not ok
