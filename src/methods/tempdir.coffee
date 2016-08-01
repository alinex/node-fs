###
Temp Directory
==================================================
This will create a new temporary directory for you. Since Node v5.10.0 you may
also use the [`mkdtemp()`](https://nodejs.org/api/fs.html#fs_fs_mkdtemp_prefix)
method but it has a slightly changed API.

In this methods you define the temporary directory with two possible strings.
First with the directory in which to create the new one and secondly a possible
prefix before the numerical part.

Examples
-------------------------------------------------

You may get a directory back without doing anything:

``` coffee
fs = require 'alinex-fs'
fs.tempdir (err, dir) ->
  console.log "Temporary directory is: " + dir
```

But don't forget to remove it if no longer needed.
###


# Node Modules
# -------------------------------------------------
path = require 'path'
crypto = require 'crypto'
os = require 'os'
# include other extended commands and helper
mkdirs = require './mkdirs'


# External Methods
# -------------------------------------------------

###
@param {String} base path under which the directory should be created (use `null`
for os default settings)
@param {String} [prefix=process title] to use before numerical part
@param {function(err, dir)} cb callback with `Error` or the path to the newly created directory
###
tempdir = module.exports.tempdir = (base, prefix = null, cb) ->
  # optional arguments
  if not cb? and typeof prefix is 'function'
    cb = prefix
    prefix = null
  if not cb? and typeof base is 'function'
    cb = base
    base = null
  base ?= os.tmpDir()
  prefix ?= path.basename process.title + '-'
  # try to create dir
  dir = path.join base, prefix + crypto.randomBytes(4).readUInt32LE(0)
  mkdirs.mkdirs dir, (err) ->
    # try again if already existing
    return tempdir base, prefix, cb if err?.code is 'EEXIST'
    # stop on any other problem
    return cb err if err
    cb null, dir

###
@param {String} {base=os settings} path under which the directory should be created
@param {String} [prefix=process title] to use before numerical part
@return {String} the path to the newly created directory
@throws {Error} if something went wrong
###
tempdirSync = module.exports.tempdirSync = (base, prefix = null) ->
  base ?= os.tmpDir()
  prefix ?= path.basename process.title + '-'
  # try to create dir
  dir = path.join base, prefix + crypto.randomBytes(4).readUInt32LE(0)
  try
    mkdirs.mkdirsSync dir
    return dir
  catch error
    # try again if already existing
    return tempdirSync base, prefix if error.code is 'EEXIST'
    # stop on any other problem
    throw error
