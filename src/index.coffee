# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = module.exports = require 'fs'
path = require 'path'

# Make dirs recursively
# -------------------------------------------------
# Create a new directory and any necessary subdirectories at `dir` with octal
# permission string `mode`.
#
# __Arguments:__
#
# * `dir`
#   Directory to create if not existing.
# * `mode` (optional)
#   Mode setting defaults to process's file mode creation mask.
# * `callback(err, made)`
#   The callback will be called just if an error occurred. It returns the first
#   directory that had to be created, if any.
mkdirs = module.exports.mkdirs = (dir, mode, cb, made) ->
  if typeof mode is 'function' or not mode
    cb = mode
    mode = 0o0777 & (~process.umask())

  made = null if not made
  mode = parseInt mode, 8 if typeof mode is 'string'
  dir = path.resolve dir

  fs.mkdir dir, mode, (err) ->
    return cb? null, made ? dir unless err
    if err.code is 'ENOENT'
      mkdirs path.dirname dir, mode, (err, made) ->
        return cb? err, made if err
        return mkdirs dir, mode, cb, made
    else if err.code is 'EEXIST'
      return cb? null, made
    cb? err, made
