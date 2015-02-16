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
find = module.exports.async = (source, options, cb , depth = 0 ) ->
  unless cb?
    cb = ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  list = []
  # Check the current file through filter options
  filter.async source, depth, options, (ok) ->
    return cb null, list unless options.lazy and ok
    list.push source
    # check source entry
    stat = if options.dereference? then fs.stat else fs.lstat
    stat source, (err, stats) ->
      if err
        return cb null, [] if options.ignoreErrors
        return cb err
      return cb null, list unless stats.isDirectory()
      # source is directory
      depth++
      fs.readdir source, (err, files) ->
        return cb err if err
        # collect files from each subentry
        async.map files.sort(), (file, cb) ->
          find path.join(source, file), options, cb, depth
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
#
# __Throw:__
#
# * `Error`
#   If anything out of order happened.
findSync = module.exports.sync = (source, options = {}, depth = 0) ->
  list = []
  return list unless options.lazy and filter.sync source, depth, options
  # Check the current file through filter options
  list.push source
  # check source entry
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  try
    stats = stat source
  catch err
    return list if options.ignoreErrors
    throw err
  return list unless stats.isDirectory()
  # source is directory
  depth++
  files = fs.readdirSync source
  # collect files from each subentry
  for file in files.sort()
    list = list.concat findSync path.join(source, file), options, depth
  return list
