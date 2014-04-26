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
# * `source`
#   Path to be searched.
# * `options`
#   Specification of files to find.
# * `callback(err, list)`
#   The callback will be called just if an error occurred. The list of found
#   entries will be given.
#
# The following options are available:
# - dereference: bool - follow symbolic links
# - mindepth: integer - levels of directories below the source
# - maxdepth: integer - levels of directories below the source
find = module.exports.async = (source, options, cb = -> ) ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  list = [source]
  # check source entry
  fs.lstat source, (err, stats) ->
    return cb err if err
    return cb null, list unless stats.isDirectory()
    # source is directory
    fs.readdir source, (err, files) ->
      return cb err if err
      # collect files from each subentry
      async.map files, (file, cb) ->
        find path.join(source, file), options, cb
      , (err, results) ->
        return cb err if err
        list = list.concat result for result in results
        cb null, list
