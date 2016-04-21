# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
os = require 'os'
# include other extended commands and helper


# Create temporary folder
# -------------------------------------------------
# __Arguments:__
#
# - `base` - path under which the directory should be created (defaults to os setting)
# - `prefix` - prefix string to use
# - `cb` - callback method
tempfile = module.exports.async = (base, prefix = null, cb) ->
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

# Create temporary folder (Synchronous)
# -------------------------------------------------
# __Arguments:__
#
# - `base` - path under which the directory should be created (defaults to os setting)
# - `prefix` - prefix string to use
# - `cb` - callback method
tempfileSync = module.exports.sync = (base, prefix = null) ->
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
