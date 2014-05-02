# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
async = require 'async'

filter = require './filter'

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
# * `depth`
#   Search depth as integer (internal parameter).
#
# The following options are available:
#
# - dereference: bool - follow symbolic links
# - mindepth: integer - levels of directories below the source
# - maxdepth: integer - levels of directories below the source
find = module.exports.async = (source, options, cb , depth = 0 ) ->
  unless cb?
    cb = ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  list = []
  # Check the current file through filter options
  filter.async source, options, (ok) ->
    min = not options.mindepth or options.mindepth <= depth
    max = not options.mmaxdepth or options.maxdepth >= depth
    list.push source if ok and min and max
    # check source entry
    fs.lstat source, (err, stats) ->
      return cb err if err
      return cb null, list unless stats.isDirectory()
      # source is directory
      fs.readdir source, (err, files) ->
        return cb err if err
        # collect files from each subentry
        async.map files, (file, cb) ->
          find path.join(source, file), options, cb, (depth+1)
        , (err, results) ->
          return cb err if err
          list = list.concat result for result in results
          cb null, list

# Find files (Synchronous)
# -------------------------------------------------
# This method will list all files and directories in the given directory.
#
# __Arguments:__
#
# * `source`
#   Path to be searched.
# * `options`
#   Specification of files to find.
# * `depth`
#   Search depth as integer (internal parameter).
#
# __Return:__
#
# * `list`
#   Returns the list of found entries
#.
# __Throw:__
#
# * `Error`
#   If anything out of order happened.
findSync = module.exports.sync = (source, options = {}, depth = 0) ->
  list = []
  # Check the current file through filter options
  min = not options.mindepth or options.mindepth <= depth
  max = not options.mmaxdepth or options.maxdepth >= depth
  list.push source if filter.sync source, options and min and max
  # check source entry
  stats = fs.lstatSync source
  return list unless stats.isDirectory()
  # source is directory
  files = fs.readdirSync source
  # collect files from each subentry
  for file in files
    list = list.concat findSync path.join(source, file), options, (depth+1)
  return list
