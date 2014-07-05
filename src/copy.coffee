# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
async = require 'async'
debug = require('debug')('fs:copy')

# include other extended commands and helper
mkdirs = require './mkdirs'
filter = require './filter'

# Copy file or directory
# -------------------------------------------------
# This method will copy a single file or complete directory like `cp -r`.
#
# __Arguments:__
#
# * `source`
#   File or directory to be copied.
# * `target`
#   File or directory to copy to.
# * `options`
#   Specification of files to find.
# * `callback(err)`
#   The callback will be called just if an error occurred.
# * `depth`
#   Search depth as integer (internal parameter).
#
# __Additional Options:__
#
# * `overwrite`
#   if set to `true` it will not fail if destination file already exists and
#   overwrite it
# * `ignore`
#   if set to `true` it will not fail if destination file already exists, skip
#   this and go on with the next file
#
copy = module.exports.async = (source, target, options, cb, depth = 0) ->
  unless cb?
    cb = ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  # check file entry
  stat = if options.dereference? then fs.stat else fs.lstat
  stat source, (err, stats) ->
    return cb err if err
    # Check the current file through filter options
    filter.async source, depth, options, (ok) ->
      if stats.isFile()
        return cb() unless ok
        # create directory if necessary
        mkdirs.async path.dirname(target), (err) ->
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
        mkdirs.async path.dirname(target), (err) ->
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
          mkdirs.async target, stats.mode, (err) ->
            return cb err if err
            async.each files, (file, cb) ->
              copy path.join(source, file), path.join(target, file), options, cb, depth
            , cb

# Copy file or directory (Synchronous)
# -------------------------------------------------
# This method will copy a single file or complete directory like `cp -r`.
#
# __Arguments:__
#
# * `source`
#   File or directory to be copied.
# * `target`
#   File or directory to copy to.
# * `options`
#   Specification of files to find.
# * `depth`
#   Search depth as integer (internal parameter).
#
# __Additional Options:__
#
# * `overwrite`
#   if set to `true` it will not fail if destination file already exists and
#   overwrite it
# * `ignore`
#   if set to `true` it will not fail if destination file already exists, skip
#   this and go on with the next file
#
# __Throw:__
#
# * `Error`
#   If anything out of order happened.
copySync = module.exports.sync = (source, target, options = {}, depth = 0) ->
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  stats = stat source
  ok = filter.sync source, depth, options
  if stats.isFile()
    return unless ok
    # create directory if neccessary
    mkdirs.sync path.dirname(target)
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
    mkdirs.sync path.dirname(target)
    resolvedPath = fs.readlinkSync source
    # make the symlink
    debug "copying link #{source} to #{target}"
    fs.symlinkSync resolvedPath, target
  else
    # source is directory
    depth++
    # copy directory
    mkdirs.sync target, stats.mode if ok
    # copy all files in directory
    debug "copying directory #{source} to #{target}"
    for file in fs.readdirSync source
      copySync path.join(source, file), path.join(target, file), options, depth

copyFile = (source, stats, target, cb) ->
  # finalize only once
  done = (err) ->
    unless cbCalled
      return cb err if err
      # fix file permissions and times
      fs.utimes target, stats.atime, stats.mtime, (err) ->
        fs.chown target, stats.uid, stats.gid, (err) ->
          fs.chmod target, stats.mode, (err) ->
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

copyFileSync = (source, stats, target) ->
  # copy file
  fs.writeFileSync target, fs.readFileSync source
  # copy permissions and times
  fs.utimesSync target, stats.atime, stats.mtime
  fs.chownSync target, stats.uid, stats.gid
  fs.chmodSync target, stats.mode
