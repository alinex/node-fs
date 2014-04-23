# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = module.exports = require 'fs'
path = require 'path'

# Add extended functionality
# -------------------------------------------------

mkdirs = require './mkdirs'
fs.mkdirs = mkdirs.mkdirs
fs.mkdirsSync = mkdirs.mkdirsSync

###
remove = require './remove'
fs.remove = remove.remove
fs.removeSync = remove.removeSync
###
