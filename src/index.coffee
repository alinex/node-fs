# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = module.exports = require 'graceful-fs'
path = require 'path'
memoizee = require 'memoizee'

# Optimize original methods
# -------------------------------------------------

# ### lstat with cached results
nodeLstat = fs.lstat
fs.xlstat = memoizee nodeLstat,
  async: true
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

# ### lstat with cached results (synchronous)
nodeLstatSync = fs.lstatSync
fs.xlstatSync = memoizee nodeLstatSync,
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

# Add extended functionality
# -------------------------------------------------

# ### Making directories with parents
mkdirs = require './mkdirs'
fs.mkdirs = mkdirs.async
fs.mkdirsSync = mkdirs.sync

# ### Find files
find = require './find'
fs.find = find.async
fs.findSync = find.sync

# ### Copy file or directory
copy = require './copy'
fs.copy = copy.async
fs.copySync = copy.sync

# ### Remove of entry with subentries
remove = require './remove'
fs.remove = remove.async
fs.removeSync = remove.sync


# meta
# find
# npmBin
