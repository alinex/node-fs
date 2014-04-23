# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = module.exports = require 'fs'
path = require 'path'

# Add extended functionality
# -------------------------------------------------

# ### Making directories with parents
mkdirs = require './mkdirs'
fs.mkdirs = mkdirs.mkdirs
fs.mkdirsSync = mkdirs.mkdirsSync

# ### Remove of entry with subentries
remove = require './remove'
fs.remove = remove.remove
fs.removeSync = remove.removeSync
