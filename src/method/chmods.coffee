###
Change Mode
=================================================
Change the files mode bits consisting of the file permission bits plus the set-user-ID,
set-group-ID, and sticky bits.

The options object is the same as used for {@link find.coffee} with the additional mode:
- `mode` - `Integer` - to be set on the matching entries
- `dereference` - `Boolean` dereference symbolic links and go into them
- `ìgnoreErrors` - `Boolean` go on and ignore IO errors

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
debug = require('debug')('fs:chmods')
fs = require 'fs'
async = require 'async'
# include other extended commands and helper
find = require './find'
parallel = require '../helper/parallel'


# Exported Methods
# ------------------------------------------------

###
@param {String} source file path or directory to search
@param {Object} options selection of files to search and change mode
@param {function(Error)} cb callback with error if something went wrong
- No file to change mode for found!
###
module.exports.chmods = (source, options, cb = ->) ->
  find.find source, options, (err, list) ->
    return cb err if err
    unless list.length or options.ignoreErrors
      return cb new Error "No file to change mode for found!"
    async.eachLimit list, parallel(options), (file, cb) ->
      debug "chmod of #{file}" if debug.enabled
      fs.chmod file, options.mode, cb
    , (err) ->
      cb err, list

###
@param {String} source file path or directory to search
@param {Object} options selection of files to search and mode
@throws {Error} if something went wrong
- No file to change mode for found!
###
module.exports.chmodsSync = (source, options) ->
  list = find.findSync source, options
  unless list.length or options.ignoreErrors
    return new Error "No file to change mode for found!"
  for file in list
    fs.chmodSync file, options.mode
  return list
