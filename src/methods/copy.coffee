###
Copy
=================================================
This will copy a single file, complete directory or selection from directory.
It will make exact copies of the files as far as possible including times, ownership
and access modes. But if some of this rights are not possible to set it will be ignored
without an explicit error.

To select which files to copy you may specify it like in the
[`find()`](find.coffee) method. But the following options may be used:

__Additional Options:__

* `overwrite` -
  if set to `true` it will not fail if destination file already exists and
  overwrite it
* `ignore` -
  if set to `true` it will not fail if destination file already exists, skip
  this and go on with the next file
###

# Node Modules
# -------------------------------------------------
fs = require 'fs'
path = require 'path'
async = require 'async'
debug = require('debug')('fs:copy')
# include other extended commands and helper
mkdirs = require './mkdirs'
filter = require './filter'


# Exported Methods
# ------------------------------------------------

###
@param {String} source path or file to be copied
@param {String} target file or directory to copy to
@param {Object} [options] specifications for check defining which files to copy
@param {function(err)} [cb] callback which is called after done with possible `Èrror`
@internal The `depth` parameter is only used internally.
@param {Integer} [depth=0] current depth in file tree
###
copy = module.exports.copy = (source, target, options, cb, depth = 0) ->
  unless cb?
    cb = ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  # check file entry
  stat = if options.dereference? then fs.stat else fs.lstat
  stat source, (err, stats) ->
    if err
      return cb() if options.ignoreErrors
      return cb err
    # Check the current file through filter options
    filter.filter source, depth, options, (ok) ->
      if stats.isFile()
        return cb() unless ok
        # create directory if necessary
        mkdirs.mkdirs path.dirname(target), (err) ->
          return cb err if err
          # copy the file
          fs.exists target, (exists) ->
            if exists and not (options.overwrite or options.ignore)
              return cb new Error "Target file already exists."
            if not exists or options.overwrite
              debug "copying file #{source} to #{target}"
              return copyFile source, stats, target, cb
            cb()
      else if stats.isSymbolicLink()
        return cb() unless ok
        # create directory if necessary
        mkdirs.mkdirs path.dirname(target), (err) ->
          return cb err if err
          debug "copying link #{source} to #{target}"
          fs.readlink source, (err, resolvedPath) ->
            return cb err if err
            # make the symlink
            fs.symlink resolvedPath, target, cb
      else
        # source is directory
        depth++
        fs.readdir source, (err, files) ->
          return cb err if err
          # copy all files in directory
          debug "copying directory #{source} to #{target}"
          # make directory
          mkdirs.mkdirs target, stats.mode, (err) ->
            return cb err if err
            async.each files, (file, cb) ->
              copy path.join(source, file), path.join(target, file), options, cb, depth
            , cb

###
@param {String} source path or file to be copied
@param {String} target file or directory to copy to
@param {Object} [options] specifications for check defining which files to copy
@throws {Error} if anything out of order happened
@internal The `depth` parameter is only used internally.
@param {Integer} [depth=0] current depth in file tree
###
copySync = module.exports.copySync = (source, target, options = {}, depth = 0) ->
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  try
    stats = stat source
  catch error
    return if options.ignoreErrors
    throw error
  ok = filter.filterSync source, depth, options
  if stats.isFile()
    return unless ok
    # create directory if neccessary
    mkdirs.mkdirsSync path.dirname(target)
    # copy the file
    exists = fs.existsSync target
    if exists and not (options.overwrite or options.ignore)
      throw new Error "Target file already exists."
    if not exists or options.overwrite
      debug "copying file #{source} to #{target}"
      return copyFileSync source, stats, target
  else if stats.isSymbolicLink()
    return unless ok
    # create directory if neccessary
    mkdirs.mkdirsSync path.dirname(target)
    resolvedPath = fs.readlinkSync source
    # make the symlink
    debug "copying link #{source} to #{target}"
    fs.symlinkSync resolvedPath, target
  else
    # source is directory
    depth++
    # copy directory
    mkdirs.mkdirsSync target, stats.mode if ok
    # copy all files in directory
    debug "copying directory #{source} to #{target}"
    for file in fs.readdirSync source
      copySync path.join(source, file), path.join(target, file), options, depth

# Helper Methods
# -------------------------------------------------------

# @param {String} source dourcepath of concrete file to copy
# @param {fs.Stats} stats file information object
# @param {String} target path to store file copy to
# @param {function(err)} cb callback after dann with possible `Error` object
copyFile = (source, stats, target, cb) ->
  # finalize only once
  done = (err) ->
    unless cbCalled
      return cb err if err
      # fix file permissions and times but ignore errors
      fs.utimes target, stats.atime, stats.mtime, ->
        fs.chown target, stats.uid, stats.gid, ->
          fs.chmod target, stats.mode, ->
            return cb()
    cbCalled = true
  # open streams
  rs = fs.createReadStream source
  ws = fs.createWriteStream target,
    mode: stats.mode
  # copy data
  ws.on 'error', done
  ws.on 'close', done
  rs.pipe ws

# @param {String} source dourcepath of concrete file to copy
# @param {fs.Stats} stats file information object
# @param {String} target path to store file copy to
# @throws `Error` if something went wrong
copyFileSync = (source, stats, target) ->
  # copy file
  fs.writeFileSync target, fs.readFileSync source
  # copy permissions and times
  fs.utimesSync target, stats.atime, stats.mtime
  fs.chownSync target, stats.uid, stats.gid
  fs.chmodSync target, stats.mode
