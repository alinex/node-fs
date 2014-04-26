# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'

# Make dirs recursively
# -------------------------------------------------
# Create a new directory and any necessary subdirectories of `dir` with octal
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
mkdirs = module.exports.async = (dir, mode, cb = -> ) ->
  # get parameter and default values
  if typeof mode is 'function' or not mode
    cb = mode
    mode = 0o0777 & (~process.umask())
  mode = parseInt mode, 8 if typeof mode is 'string'
  dir = path.resolve dir
  # try to create directory
  fs.mkdir dir, mode, (err) ->
    # return on success
    return cb null, dir ? dir unless err
    if err.code is 'ENOENT'
      # parent directory missing
      mkdirs path.dirname(dir), mode, (err, made) ->
        return cb err, made if err
        # try again if parent was successful created
        fs.mkdir dir, mode, (err) ->
          cb err, made
    else if err.code is 'EEXIST'
      # directory already exists
      return cb()
    else
      # other error let's fail the action
      cb err


# Make dirs recursively (Synchronous)
# -------------------------------------------------
# Create a new directory and any necessary subdirectories of `dir` with octal
# permission string `mode`.
#
# __Arguments:__
#
# * `dir`
#   Directory to create if not existing.
# * `mode` (optional)
#   Mode setting defaults to process's file mode creation mask.
#
# __Return:__
#
# * `made`
#   Returns the directory that had to be created, if any.
#
# __Throw:__
#
# * `Error`
#   If anything out of order happened.
mkdirsSync = module.exports.sync = (dir, mode) ->
  # get parameter and default values
  if typeof mode is 'function' or not mode
    cb = mode
    mode = 0o0777 & (~process.umask())
  mode = parseInt mode, 8 if typeof mode is 'string'
  dir = path.resolve dir
  # try to create directory
  try
    fs.mkdirSync dir, mode
    return dir
  catch err
    if err.code is 'ENOENT'
      # parent directory missing
      made = mkdirsSync path.dirname(dir), mode
      # try again if parent was successful created
      fs.mkdirSync dir, mode
      return made
    else if err.code is 'EEXIST'
      # directory already exists
      return null
    else
      # other error let's fail the action
      throw err
