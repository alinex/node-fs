# Extension of nodes fs utils
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
fs = require 'graceful-fs'
path = require 'path'
memoizee = require 'memoizee'

# Clone original fs
# -------------------------------------------------
afs = module.exports = {}
for name, value of fs
  afs[name] = value


# Optimize original methods
# -------------------------------------------------

# ### stat with cached results
afs.stat = memoizee fs.stat,
  async: true
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

# ### statSync with cached results (synchronous)
afs.statSync = memoizee fs.statSync,
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

# ### lstat with cached results
afs.lstat = memoizee fs.lstat,
  async: true
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

# ### lstatSync with cached results (synchronous)
afs.lstatSync = memoizee fs.lstatSync,
  maxAge: 1000 # expiration time in milliseconds
  max: 1000 # limit number of elements

# Add extended functionality
# -------------------------------------------------
for name in [
  'mkdirs', 'find', 'copy', 'remove', 'move'
  'npmbin', 'tempdir'
]
  commands = require './' + name
  afs[name] = commands.async
  afs[name+'Sync'] = commands.sync
