# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
async = require 'async'

# Remove path recursively
# -------------------------------------------------
# This method will remove the given `path` entry and if it is a directory it
# will also remove any containing data.
#
# __Arguments:__
#
# * `path`
#   File or directory to be removed.
# * `callback(err, removed)`
#   The callback will be called just if an error occurred. It returns the
#   file entry which was removed, if any.
remove = module.exports.remove = (file, cb) ->
  # get parameter and default values
  file = path.resolve file
  fs.unlink file, (err) ->
    # correctly removed
    return cb? null, file unless err
    # already removed
    return cb? null if err.code is 'ENOENT'
    # some other problem, give up
    return cb? err unless err.code is 'EISDIR'
    # it's a directory
    dir = file
    # try to remove directory
    fs.rmdir dir, (err) ->
      # correctly removed
      return cb? null, dir unless err
      # some other problem, give up
      return cb? err unless err.code is 'ENOTEMPTY'
      # directory not empty
      fs.readdir dir, (err, files) ->
        return cb? err if err
        # remove all entries in directory
        async.each files, (file, cb) ->
          remove path.join(dir, file), cb
        , (err) ->
          return cb? err if err
          # try to remove upper directory again
          fs.rmdir dir, (err) ->
            return cb? err if err
            cb? null, dir


# Remove path recursively (Synchronous)
# -------------------------------------------------
# Removes the given path and any containing files or subdirectories.
#
# __Arguments:__
#
# * `path`
#   File or directory to create if not existing.
#
# __Return:__
#
# * `removed`
#   Returns the file entry which was removed.
#
# __Throw:__
#
# * `Error`
#   If anything out of order happened.
removeSync = module.exports.removeSync = (file) ->
  # get parameter and default values
  file = path.resolve file
  try
    fs.unlinkSync file
    # correctly removed
    return file
  catch err
    # already removed
    return null if err.code is 'ENOENT'
    # some other problem
    throw err unless err.code is 'EISDIR'
    # it's a directory
    dir = file
    try
      # try to remove directory
      fs.rmdirSync dir
      # correctly removed
      return dir
    catch err
      # some other problem
      throw err unless err.code is 'ENOTEMPTY'
      # directory is not empty
      files = fs.readdirSync dir
      for file in files
        removeSync path.join dir, file
      # try to remove upper directory again
      fs.rmdirSync dir
      return dir
