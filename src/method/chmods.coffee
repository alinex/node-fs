###
Change Mode
=================================================
Change the files mode bits consisting of the file permission bits plus the set-user-ID,
set-group-ID, and sticky bits.

The options object is the same as used for {@link find.coffee} with the additional mode:
- `mode` - `Integer` - to be set on the matching entries
- `dereference` - `Boolean`
- `ignoreErrors` - `Boolean`

The file mode is a bit mask with the following bits (octal notation):

| Name |  BIT  | Description                    |
|:----:|:-----:| ------------------------------ |
| SUID | 04000 | set process effective user ID  |
| SGID | 02000 | set process effective group ID |
| SVTX | 01000 | sticky bit                     |
| RUSR | 00400 | read by owner                  |
| WUSR | 00200 | write by owner                 |
| XUSR | 00100 | execute/access by owner        |
| RGRP | 00040 | read by group                  |
| WGRP | 00020 | write by group                 |
| XGRP | 00010 | execute/access by group        |
| ROTH | 00004 | read by others                 |
| WOTH | 00002 | write by others                |
| XOTH | 00001 | execute/access by others       |

To change the file mode you have to be privileged to do so.
###


# Node Modules
# -------------------------------------------------
fs = require 'fs'
path = require 'path'
async = require 'async'
debug = require('debug')('fs:chmods')


# Exported Methods
# ------------------------------------------------

###
@param {String} file file path or directory to search
@param {Object} options selection of files to search and mode
@param {function(<Error>)} cb callback with error if something went wrong
###
chmods = module.exports.chmods = (file, options, cb = ->) ->
  # check file entry
  stat = if options.dereference? then fs.stat else fs.lstat
  stat file, (err, stats) ->
    # return if not existing
    if err
      return cb() if err.code is 'ENOENT' or options.ignoreErrors
      return cb err
    # change inode ownership
    fs.chmod file, options.mode, (err) ->
      return cb err if err
      return cb() unless stats.isDirectory()
      # do the same for contents of directory
      dir = file
      debug "chmod directory contents of #{dir}"
      fs.readdir file, (err, files) ->
        return cb err if err
        # remove all files in directory
        async.each files, (file, cb) ->
          chmods path.join(dir, file), options, cb
        , cb

###
@param {String} file file path or directory to search
@param {Object} options selection of files to search and mode
@throws {Error} if something went wrong
###
chmodsSync = module.exports.chmodsSync = (file, options) ->
  # check file entry
  stat = if options.dereference? then fs.statSync else fs.lstatSync
  try
    stats = stat file
  catch error
    # return if already removed
    return if error.code is 'ENOENT' or options.ignoreErrors
    throw error
  # change inode ownership
  fs.chmodSync file, options.mode
  return unless stats.isDirectory()
  # do the same for contents of directory
  dir = file
  debug "chmod directory contents of #{dir}"
  # remove all files in directory
  for file in fs.readdirSync dir
    chmodsSync path.join(dir, file), options
