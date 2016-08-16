###
Move Files
=================================================
This will move a single file, complete directory or selection from directory. This
is the same as copy the files and remove them afterwards.

To select which files to copy and how to work you can use the following options:
- `filter` - `Array<Object>|Object` {@link filter.coffee}
- `clean` - `Boolean` if set to `true` it will clean old files from target.
- `overwrite` - `Boolean` if set to `true` it will not fail if destination file
  already exists and overwrite it
- `ignore` - `Boolean` it will not fail if destination file already exists
  but skip this and go on with the next file
- `noempty` - `Boolean` set to `true to don't create empty directories while no
  files to copy into`
- `dereference` - `Boolean` dereference symbolic links and go into them
- `ìgnoreErrors` - `Boolean` go on and ignore IO errors
- `parallel` - `Integer` number of maximum parallel calls in asynchronous run
  (defaults to half of open files limit per process on the system)


__Example:__

``` coffee
fs = require 'alinex-fs'
fs.copy '/tmp/some/directory', '/new/destination', (err) ->
  return console.error err.message if err
  console.log "Directory copied!"
```

You may also use options to specify which files within the source directory to
move.
###


# Node Modules
# -------------------------------------------------
debug = require('debug')('fs:move')
fs = require 'fs'
path = require 'path'
async = require 'async'
posix = require 'posix'
# include other extended commands and helper
mkdirs = require './mkdirs'
copy = require './copy'
remove = require './remove'


# Setup
# ------------------------------------------------
# Maximum parallel processes is half of the soft limit for open files if not given
# in the options.
PARALLEL = Math.floor posix.getrlimit('nofile').soft / 2


# Exported Methods
# ------------------------------------------------

###
@param {String} source path or file to be copied
@param {String} target file or directory to copy to
@param {Object} [options] specifications for check defining which files to copy
@param {function(<Error>)} [cb] callback which is called after done with possible `Èrror`
###
module.exports.move = (source, target, options = {}, cb = ->) ->
  if typeof options is 'function' or not options
    cb = options ? ->
    options = {}
  debug "move filepath #{source} to #{target}."
  # collect methods to run
  async.series [
    # remove old target first
    (cb) ->
      return cb() unless options.clean
      remove.remove target, cb
    # create parent directories
    (cb) ->
      mkdirs.mkdirs path.dirname(target), cb
    # try to rename file
    (cb) ->
      return cb() if options
      fs.rename source, target, (err) ->
        return cb null, target unless err
        copyRemove source, target, options, cb
    # direct copy/remove
    (cb) ->
      return cb null, target unless options
      copyRemove source, target, options, cb
  ], cb

###
@param {String} source path or file to be copied
@param {String} target file or directory to copy to
@param {Object} [options] specifications for check defining which files to copy
@throws {Error} if anything out of order happened
###
module.exports.moveSync = (source, target, options = {}) ->
  debug "move filepath #{source} to #{target}."
  # remove old target first
  if options.clean
    remove.removeSync target
  # create parent directories
  mkdirs.mkdirsSync path.dirname target
  # try to rename file
  unless options
    try
      fs.renameSync source, target
      return target
    catch error
      throw error unless options.ignoreErrors
      return copyRemoveSync source, target, options
  # direct copy/remove
  copyRemoveSync source, target, options


# Helper methods
# -------------------------------------------------

# @param {String} source path or file to be copied
# @param {String} target file or directory to copy to
# @param {Object} [options] specifications for check defining which files to copy
# @param {function(err)} [cb] callback which is called after done with possible `Èrror`
copyRemove = (source, target, options, cb) ->
  # copy to target
  copy.copy source, target, options, (err, list) ->
    return cb err if err
    # finally remove source
    list.reverse()
    async.eachLimit list, (file, cb) ->
      remove.remove file, options, cb
    , cb

# @param {String} source path or file to be copied
# @param {String} target file or directory to copy to
# @param {Object} [options] specifications for check defining which files to copy
# @throws {Error} if anything out of order happened
copyRemoveSync = (source, target, options) ->
  # copy to target
  copy.copySync source, target, options
  # finally remove source
  remove.removeSync source, options
