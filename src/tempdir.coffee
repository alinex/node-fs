# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug')('fs:tempdir')
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
tempdir = module.exports.async = (base, prefix = '', cb) ->
  # optional arguments
  if not cb? and typeof prefix is 'function'
    cb = prefix
    prefix = ''
  if not cb? and typeof base is 'function'
    cb = base
    base = ''
  base ?= os.tmpDir()
  # try to create dir
  dir = path.join base, prefix + crypto.randomBytes(4).readUInt32LE(0)
  fs.mkdir dir, (err) ->
    # try again if already existing
    return tempdir base, prefix, cb if err?.code is 'EEXIST'
    # stop on any other problem
    return cb err if err
    cb null, dir

# Create temporary folder (Synchronous)
# -------------------------------------------------
# __Arguments:__
#
# - `base` - path under which the directory should be created (defaults to os setting)
# - `prefix` - prefix string to use
# - `cb` - callback method
tempdir = module.exports.sync = (base, prefix = '') ->
  base ?= os.tmpDir()
  # try to create dir
  dir = path.join base, prefix + crypto.randomBytes(4).readUInt32LE(0)
  try
    fs.mkdirSync dir
    return dir
  catch err
    # try again if already existing
    return tempdir base, prefix if err.code is 'EEXIST'
    # stop on any other problem
    throw err
