###
Make Directories
=================================================
The basic [`mkdir()`](https://nodejs.org/api/fs.html#fs_fs_mkdir_path_mode_callback)
will only create one level of directory. While this extension gives additional methods
which will also create the full path if possible.

If an `EEXIST` code will be thrown internally this signals that the directory is already
there so this methods will succeed without doing anything and without `Error`. All
other errors will be given back.

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
debug = require('debug') 'fs:mkdirs'
chalk = require 'chalk'
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
  debug "directory #{dir}?"
  fs.mkdir dir, mode, (err) ->
    # return on success
    unless err
      debug "directory #{dir} created"
      return cb null, dir ? dir
    if err.code is 'ENOENT'
      debug chalk.grey "-> parent is missing"
      # parent directory missing
      mkdirs path.dirname(dir), mode, (err, made) ->
        return cb err, made if err
        # try again if parent was successful created
        fs.mkdir dir, mode, (err) ->
          # return on success
          unless err
            debug "directory #{dir} created"
            return cb null, made
          if err.code is 'EEXIST'
            # directory already exists
            debug chalk.grey "-> directory #{dir} is there, now"
            cb null, made
          else
            cb err, made
    else if err.code is 'EEXIST'
      # directory already exists
      debug chalk.grey "-> directory #{dir} was already there"
      cb()
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
    debug "directory #{dir} created"
    return dir
  catch error
    if error.code is 'ENOENT'
      # parent directory missing
      debug chalk.grey "-> parent is missing"
      made = mkdirsSync path.dirname(dir), mode
      # try again if parent was successful created
      try
        fs.mkdirSync dir, mode
        debug "directory #{dir} created"
        return made
      catch error
        if error.code is 'EEXIST'
          debug chalk.grey "-> directory #{dir} is there, now"
          return made
        throw error
    else if error.code is 'EEXIST'
      # directory already exists
      debug chalk.grey "directory #{dir} was already there"
      return null
    else
      # other error let's fail the action
      throw error


###
Debugging
------------------------------------------------
Debugging is possible using environment setting:

    DEBUG=fs:mkdirs    -> shows each level of cloning

    fs:mkdirs directory /home/alex/github/node-fs/test/temp/with/multiple/dirs? +0ms
    fs:mkdirs -> parent is missing +1ms
    fs:mkdirs directory /home/alex/github/node-fs/test/temp/with/multiple? +1ms
    fs:mkdirs -> parent is missing +0ms
    fs:mkdirs directory /home/alex/github/node-fs/test/temp/with? +0ms
    fs:mkdirs -> parent is missing +0ms
    fs:mkdirs directory /home/alex/github/node-fs/test/temp? +0ms
    fs:mkdirs directory /home/alex/github/node-fs/test/temp created +0ms
    fs:mkdirs directory /home/alex/github/node-fs/test/temp/with created +29ms
    fs:mkdirs directory /home/alex/github/node-fs/test/temp/with/multiple created +0ms
    fs:mkdirs directory /home/alex/github/node-fs/test/temp/with/multiple/dirs created +0ms
###
