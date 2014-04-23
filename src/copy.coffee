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
# * `callback(err)`
#   The callback will be called just if an error occurred.
copy = module.exports.copy = (source, target, cb = -> ) ->
  fs.lstat source, (err, stats) ->
    return cb err if err
    if stats.isFile()
      # create directory if neccessary
      mkdirs.mkdirs path.dirname(dest), (err) ->
        return cb err if err
        # copy the file
        copyFile source, stats, target, cb
    else if stats.isSymbolicLink()
      # create directory if neccessary
      mkdirs.mkdirs path.dirname(dest), (err) ->
        return cb err if err
        fs.readlink source, (err, resolvedPath) ->
          return cb err if err
          fs.symlink resolvedPath, target, cb
    else
      # source is directory
      fs.readdir source, (err, files) ->
        return cb err if err
        # copy directory
        mkdirs.mkdirs target, stats.mode, (err) ->
          return cb err if err
          # copy all files in directory
          async.each files, (file, cb) ->
            copy path.join(source, file), path.join(target, file), cb
          , cb

copyFile = (source, stats, target, cb) ->
    # open streams
    rs = fs.createReadStream source
    ws = fs.createWriteStream target
      mode: stats.mode
    # copy data
    ws.on 'error', done
    ws.on 'close', -> done()
    rs.pipe ws
    # send callback only once
    done = (err) ->
      cb err unless cbCalled
      cbCalled = true

