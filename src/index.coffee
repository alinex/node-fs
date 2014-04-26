# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = module.exports = require 'graceful-fs'
path = require 'path'

# Add extended functionality
# -------------------------------------------------

# ### Making directories with parents
mkdirs = require './mkdirs'
fs.mkdirs = mkdirs.async
fs.mkdirsSync = mkdirs.sync

# ### Remove of entry with subentries
remove = require './remove'
fs.remove = remove.async
fs.removeSync = remove.sync

# ### Find files
find = require './find'
fs.find = find.async
#fs.findSync = find.sync

# ### Meta data
lstat = require './lstat'
fs.lstatOrig = fs.lstat
fs.lstat = lstat.async

# ### Copy file or directory
#copy = require './copy'
#fs.copy = copy.async
#fs.copySync = copy.sync

# meta
# find
# npmBin
