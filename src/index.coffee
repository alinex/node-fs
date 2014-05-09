# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'graceful-fs'
path = require 'path'
memoizee = require 'memoizee'

# Clone original fs
# -------------------------------------------------
afs = module.exports = {}
for name, value of fs
  afs[name] = value


# Optimize original methods
# -------------------------------------------------

# ### stat with cached results
afs.stat = memoizee fs.stat,
  async: true
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

# ### statSync with cached results (synchronous)
afs.statSync = memoizee fs.statSync,
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

# ### lstat with cached results
afs.lstat = memoizee fs.lstat,
  async: true
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

# ### lstatSync with cached results (synchronous)
afs.lstatSync = memoizee fs.lstatSync,
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

# Add extended functionality
# -------------------------------------------------

# ### Making directories with parents
mkdirs = require './mkdirs'
afs.mkdirs = mkdirs.async
afs.mkdirsSync = mkdirs.sync

# ### Find files
find = require './find'
afs.find = find.async
afs.findSync = find.sync

# ### Copy file or directory
copy = require './copy'
afs.copy = copy.async
afs.copySync = copy.sync

# ### Remove of entry with subentries
remove = require './remove'
afs.remove = remove.async
afs.removeSync = remove.sync

# ### Find bin in npm packages
npmbin = require './npmbin'
afs.npmbin = npmbin.async
afs.npmbinSync = npmbin.sync

