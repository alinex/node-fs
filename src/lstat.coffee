# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
async = require 'async'

# Find files
# -------------------------------------------------
# This method will list all files and directories in the given directory.
#
# __Arguments:__
#
# * `file`
#   Path to be searched.
# * `callback(err, result`
#   The callback will be called just if an error occurred. The result will
# contain all file information:
#
#     dev: 16777222       // device on which file resides
#     rdev: 0             // integer of device type (platform dependent)
#     ino: 3199990        // inode number of file
#     nlink: 1            // number of hard links to file
#     mode: 33188         // permission bits of stat (platform dependent)
#     uid: 503            // owner id
#     gid: 2014           // group owner id
#     size: 0             // size in bytes
#     blocks: 0           // number of allocated blocks
#     blksize: 4096       // native file system’s block size
#     atime: Sat Apr 26 2014 21:38:24 GMT+0200 (CEST)   // access time (Date)
#     mtime: Sat Apr 26 2014 21:38:24 GMT+0200 (CEST)   // modification time (Date)
#     ctime: Sat Apr 26 2014 21:38:24 GMT+0200 (CEST)   // creation time (Date)
#     ftype: 'file'       // string identifies the type of file
#     // file, directory, link, blockDevice, characterDevice, fifo, socket or other
lstat = module.exports.async = (file, cb = -> ) ->
  # check source entry
  fs.lstatOrig file, (err, stats) ->
    return cb err if err
    stats.ftype = switch
      when stats.isFile() then 'file'
      when stats.isDirectory() then 'directory'
      when stats.isSymbolicLink() then 'link'
      when stats.isBlockDevice() then 'blockDevice'
      when stats.isCharacterDevice() then 'characterDevice'
      when stats.isFIFO() then 'fifo'
      when stats.isSocket() then 'socket'
      else 'other'
    cb null, stats

# cache data with lru cache
# -> cache object
# -> set maxnum
# -> no cache if max reached
# clear cache method
# -> for one file
# -> for all
# -> sync