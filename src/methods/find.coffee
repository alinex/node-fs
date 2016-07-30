###
Find
=================================================
This is a powerfull method to search for files on the local filesystem. It works
recursively with multiple checks and to get a file list as quick as possible.
###


# Node Modules
# -------------------------------------------------
debug = require('debug')('fs:find')
fs = require 'fs'
path = require 'path'
async = require 'async'
# helper modules
filter = require './filter'


# Setup
# ------------------------------------------------
PARALLEL = 10


# Exported Methods
# ------------------------------------------------

###
@param {String} search source path to be searched in
@param {Object} [options] specifications for check defining which files to list
@param {function(err, list)} [cb] callback which is called after done with an `Èrror`
or the complete list of files found as `Àrray`
@internal The `depth` parameter is only used internally.
@param {Integer} [depth=0] current depth in file tree
###
find = module.exports.find = (source, options, cb , depth = 0 ) ->
  unless cb?
    cb = ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  list = []
  debug "check #{source}"
  # Check the current file through filter options
#  sourceCheck = if depth then source else '.'
  filter.filter source, depth, options, (ok) ->
    return cb null, list if ok is undefined
    list.push source if ok
    # check source entry
    stat = if options.dereference? then fs.stat else fs.lstat
    stat source, (err, stats) ->
      if err
        return cb null, [] if options?.ignoreErrors
        return cb err
      return cb null, list unless stats.isDirectory()
      # source is directory
      debug "going deeper into #{source} directory"
      depth++
      fs.readdir source, (err, files) ->
        return cb err if err
        # collect files from each subentry
        async.mapLimit files.sort(), PARALLEL, (file, cb) ->
          find path.join(source, file), options, cb, depth
        , (err, results) ->
          return cb err if err
          for result in results
            list = list.concat result
          cb null, list

###
@param {String} search source path to be searched in
@param {Object} [options] specifications for check defining which files to list
@return {Array} complete list of files found
@throws {Error} if anything out of order happened
@internal The `depth` parameter is only used internally.
@param {Integer} [depth=0] current depth in file tree
###
findSync = module.exports.findSync = (source, options = {}, depth = 0) ->
  list = []
  ok = filter.filterSync source, depth, options
  return list if options.lazy and not ok
  # Check the current file through filter options
  list.push source if ok
  # check source entry
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  try
    stats = stat source
  catch error
    return list if options.ignoreErrors
    throw error
  return list unless stats.isDirectory()
  # source is directory
  depth++
  files = fs.readdirSync source
  # collect files from each subentry
  for file in files.sort()
    list = list.concat findSync path.join(source, file), options, depth
  return list
