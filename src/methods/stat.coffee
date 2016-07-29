###
File Stats
=================================================
The [default stat](https://nodejs.org/api/fs.html#fs_fs_stat_path_callback) is
extended by cached results. The io lookup result is cached for one second, so that
multiple calls don't check on disk each time.
There are `stat()` and `lstat()` methods available which differ in the handling of
softlinks. While `stat()` will follow the softlink and analyze the file it is pointing
to, `lstat()` will analyse the softlink inode itself.

Stats objects returned from one of the stats-methods have the following methods:
- `isFile()` - `Boolean` true if this is a plain file
- `isDirectory()` - `Boolean` true if this is a directory
- `isBlockDevice()` - `Boolean` true if this is a block device
- `isCharacterDevice()` - `Boolean` true if this is a character device
- `isSymbolicLink()` - `Boolean` true if this is a symbolic link (only possible with `lstat()`)
- `isFIFO()` - `Boolean` true if this is a FIFO pipe
- `isSocket()` - `Boolean` true if this is a UNIX socket

And if it is a file also the following properties:
- `dev` - (i.e. 2114)
- `ino` - (i.e. 48064969)
- `mode` - (i.e. 33188)
- `nlink` - (i.e. 1)
- `uid` - (i.e. 85)
- `gid` - (i.e. 100)
- `rdev` - (i.e. 0)
- `size` - (i.e. 527)
- `blksize` - (i.e. 4096)
- `blocks` - (i.e. 8)
- `atime` - `Date` of last access of file (i.e. Mon, 10 Oct 2011 23:24:11 GMT)
- `mtime` - `Date` of last file modification (i.e. Mon, 10 Oct 2011 23:24:11 GMT)
- `ctime` - `Date` of last inode change time (i.e. Mon, 10 Oct 2011 23:24:11 GMT)
- `birthtime` - `Date` of file creation (i.e. Mon, 10 Oct 2011 23:24:11 GMT)
###


# Node Modules
# -------------------------------------------------
fs = require 'graceful-fs'
memoizee = require 'memoizee'


# Exported Methods
# ------------------------------------------------

###
@name stat()
@param {String|Buffer} path local path to check
@param {function(err, stats)} cb callback which gets an `Error` or a `Stats` object.
###
module.exports.stat = memoizee fs.stat,
  async: true
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

###
@name statSync()
@param {String|Buffer} path local path to check
@return {Stats} an statss objects
@throws {Error} if io problems occure
###
module.exports.statSync = memoizee fs.statSync,
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

###
@name lstat()
@param {String|Buffer} path local path to check
@param {function(err, stats)} cb callback which gets an `Error` or a `Stats` object.
###
module.exports.lstat = memoizee fs.lstat,
  async: true
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

###
@name lstatSync()
@param {String|Buffer} path local path to check
@return {Stats} an statss objects
@throws {Error} if io problems occure
###
module.exports.lstatSync = memoizee fs.lstatSync,
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements
