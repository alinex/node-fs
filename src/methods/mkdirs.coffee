###
Make Directories
=================================================
The basic [`mkdir()`](https://nodejs.org/api/fs.html#fs_fs_mkdir_path_mode_callback)
will only create one level of directory. While this extension gives additional methods
which will also create the full path if possible.

If an `EEXIST` code will be thrown this signals that the directory is already there so
this methods will succeed without doing anything and without `Error`. All other errors
will be given back.

Example Use
---------------------------------------------------
``` coffee
fs = require 'alinex-fs'
fs.mkdirs '/tmp/some/directory', (err, made) ->
  return console.error err if err
  if made
    console.log "Directory starting from #{made} was created."
  console.log 'Directory now exists!'
```
###


# Node Modules
# -------------------------------------------------
fs = require 'fs'
path = require 'path'


###
Exported Methods
------------------------------------------------
###

###
@param {String} dir directory path to create
@param {String|Integer} [mode] the permission mode for the directories (may be given
as string like '775')
@param {function(<Error>, <Integer>)} cb callback method given an `Error`, the path of the
first directory which was created or `null` if nothing had to be done
###
mkdirs = module.exports.mkdirs = (dir, mode, cb = -> ) ->
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


# Exported Methods
# ------------------------------------------------

###
@param {String} dir directory path to create
@param {String|Integer} [mode] the permission mode for the directories (may be given
as string like '775')
@return {String} the path of the first directory which was created or `null` if
nothing had to be done
@throws {Error} if anything out of order happened
###
mkdirsSync = module.exports.mkdirsSync = (dir, mode) ->
  # get parameter and default values
  if typeof mode is 'function' or not mode
    mode = 0o0777 & (~process.umask())
  mode = parseInt mode, 8 if typeof mode is 'string'
  dir = path.resolve dir
  # try to create directory
  try
    fs.mkdirSync dir, mode
    return dir
  catch error
    if error.code is 'ENOENT'
      # parent directory missing
      made = mkdirsSync path.dirname(dir), mode
      # try again if parent was successful created
      fs.mkdirSync dir, mode
      return made
    else if error.code is 'EEXIST'
      # directory already exists
      return null
    else
      # other error let's fail the action
      throw error
