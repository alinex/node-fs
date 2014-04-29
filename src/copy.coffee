# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
async = require 'async'

# include other extended commands
mkdirs = require './mkdirs'

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
copy = module.exports.async = (source, target, options, cb = -> ) ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  fs.lstat source, (err, stats) ->
    return cb err if err
    if stats.isFile()
      # create directory if neccessary
      mkdirs.async path.dirname(target), (err) ->
        return cb err if err
        # copy the file
        copyFile source, stats, target, cb

    else if stats.isSymbolicLink()
      # create directory if neccessary
      mkdirs.async path.dirname(target), (err) ->
        return cb err if err
        fs.readlink source, (err, resolvedPath) ->
          return cb err if err
          # make the symlink
          fs.symlink resolvedPath, target, cb
    else
      # source is directory
      fs.readdir source, (err, files) ->
        return cb err if err
        # copy directory
        mkdirs.async target, stats.mode, (err) ->
          return cb err if err
          # copy all files in directory
          async.each files, (file, cb) ->
            copy path.join(source, file), path.join(target, file), cb
          , cb

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

  # check if copy is possible
  fs.exists target, (err, exists) ->
    return cb err if err
    if exists
      return new Error "Target file already exists."
    # open streams
    rs = fs.createReadStream source
    ws = fs.createWriteStream target,
      mode: stats.mode
    # copy data
    ws.on 'error', done
    ws.on 'close', done
    rs.pipe ws

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
#
# __Throw:__
#
# * `Error`
#   If anything out of order happened.
copySync = module.exports.sync = (source, target, options = {} ) ->
  stats = fs.lstatSync source
  if stats.isFile()
    # create directory if neccessary
    mkdirs.sync path.dirname(target)
    # copy the file
    copyFileSync source, stats, target
  else if stats.isSymbolicLink()
    # create directory if neccessary
    mkdirs.sync path.dirname(target)
    resolvedPath = fs.readlinkSync source
    # make the symlink
    fs.symlinkSync resolvedPath, target
  else
    # source is directory
    # copy directory
    mkdirs.sync target, stats.mode
    # copy all files in directory
    for file in fs.readdirSync source
      copySync path.join(source, file), path.join(target, file)

copyFileSync = (source, stats, target) ->
  if fs.existsSync target
    throw new Error "Target file already exists."
  # copy file
  fs.writeFileSync target, fs.readFileSync source
  # copy permissions and times
  fs.utimesSync target, stats.atime, stats.mtime
  fs.chownSync target, stats.uid, stats.gid
  fs.chmodSync target, stats.mode
