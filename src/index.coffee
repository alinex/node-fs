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
#
# The additional parameter `made` contains the first directory to be created
# and is only used internally.
mkdirs = module.exports.mkdirs = (dir, mode, cb) ->
  # get parameter and default values
  if typeof mode is 'function' or not mode
    cb = mode
    mode = 0o0777 & (~process.umask())
  made = null if not made
  mode = parseInt mode, 8 if typeof mode is 'string'
  dir = path.resolve dir
  # try to create directory
  fs.mkdir dir, mode, (err) ->
    # return on success
    return cb? null, made ? dir unless err
    # parent directory missing
    if err.code is 'ENOENT'
      mkdirs path.dirname(dir), mode, (err, made) ->
        return cb? err, made if err
        # try again if parent was successful created
        mkdirs dir, mode, cb
    else if err.code is 'EEXIST'
      # directory already exists
      return cb? null, made
    else
      # other error let's fail the action
      cb? err, made

