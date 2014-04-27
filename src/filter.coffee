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
#   File to check against filter
# * `options`
#   Specification of files to find.
# * `callback(err, list)`
#   The callback will be called just if an error occurred. The list of found
#   entries will be given.
#
# The following options are available:
# minmatch
# - include:
# - exclude:
# lstat
# - ftype: string - type of entry like in lstat
# - atime: integer - accessed within last x seconds
# - mtime: integer - modified within last x seconds
# - ctime: integer - created within last x seconds
# - uid: integer - only files from this user
# - gid: integer - only files from this group
# - minsize: integer - file size in bytes
# - maxsize: integer - file size in bytes
module.exports.async = (file, options, cb = -> ) ->
  fs.lstat file, (err, stats) ->
    return cb err if err
    cb null, true
