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
fs.nodeLstat = fs.lstat
fs.lstat = fs.nodeLstat
  async: true
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

# ### lstat with cached results (synchronous)
fs.nodeLstatSync = fs.lstatSync
fs.lstatSync = fs.nodeLstatSync
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
