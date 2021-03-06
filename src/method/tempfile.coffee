###
Temp File
=================================================
This will create a new temporary file for you. Like in [`tempdir()`](tempdir.coffee)
you may give a specific path and prefix before the numeral file part.

Examples
-------------------------------------------------

You may get a file back without doing anything:

``` coffee
fs = require 'alinex-fs'
fs.tempfile (err, dir) ->
  console.log "Temporary file is: " + dir
```

But don't forget to remove it if no longer needed.
###


# Node Modules
# -------------------------------------------------
fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
os = require 'os'


# External Methods
# -------------------------------------------------

###
@param {String} base path under which the directory should be created (use `null`
to make it in the os default directory)
@param {String} [prefix=process title] to use before numerical part
@param {function(<Error>, <String>)} cb callback with `Error` or the path to the newly created file
###
tempfile = module.exports.tempfile = (base, prefix = null, cb) ->
  # optional arguments
  if not cb? and typeof prefix is 'function'
    cb = prefix
    prefix = null
  if not cb? and typeof base is 'function'
    cb = base
    base = null
  base ?= os.tmpDir()
  prefix ?= path.basename process.title + '-'
  # try to create file
  file = path.join base, prefix + crypto.randomBytes(4).readUInt32LE(0)
  fs.open file, 'wx', (err, fd) ->
    # try again if already existing
    return tempfile base, prefix, cb if err?.code is 'EEXIST'
    # stop on any other problem
    return cb err if err
    fs.close fd, ->
      cb null, file

###
@param {String} {base=os settings} path under which the directory should be created
@param {String} [prefix=process title] to use before numerical part
@return {String} the path to the newly created directory
@throws {Error} if something went wrong
###
tempfileSync = module.exports.tempfileSync = (base, prefix = null) ->
  base ?= os.tmpDir()
  prefix ?= path.basename process.title + '-'
  # try to create dir
  file = path.join base, prefix + crypto.randomBytes(4).readUInt32LE(0)
  try
    fs.closeSync fs.openSync file, 'wx'
    return file
  catch error
    # try again if already existing
    return tempfileSync base, prefix if error.code is 'EEXIST'
    # stop on any other problem
    throw error
