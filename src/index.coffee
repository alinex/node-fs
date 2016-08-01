###
API Usage
=================================================
For the [standard](https://nodejs.org/api/fs.html) node.js functions everything is
the same as far as not listed below.

As the default methods all can be used synchroneous and asynchroneous.
###


# Node Modules
# -------------------------------------------------
fs = require 'graceful-fs'


# Clone original fs
# -------------------------------------------------
afs = module.exports = {}
for name, value of fs
  afs[name] = value


###
All the extended functions use the same naming convention as the node core, making
the use nearly natural. And you can still use the native Node.js methods, also.

Some of the native methods are slightly changed:
- [stat/lstat](stat.coffee) - file stat retrieval (with caching)

Additional methods:
- [mkdirs](mkdirs.coffee) - recursive create depth directory with it's parents
- [npmdir](npmdir.coffee) - find binary in NPM path
- [tempdir](tempdir.coffee) - create temporary directory
- [tempfile](tempfile.coffee) - create temporary file

Working on multiple files using filter rules:
- [find](find.coffee) - search for files or directories
- [copy](copy.coffee) - copy file, directory or selection
- [move](move.coffee) - move file, directory or selection
- [remove](remove.coffee) - remove file, directory or selection
- [touch](touch.coffee) - touch file
- [chowns](chowns.coffee) - change ownership of file, directory or selection
- [chmods](chmods.coffee) - change access rights of file, directory or selection
###

# Add extended functionality
# -------------------------------------------------
for name in [
  'stat'
  'mkdirs', 'find', 'copy', 'remove', 'move'
  'npmbin', 'tempdir', 'tempfile', 'touch'
  'chowns', 'chmods'
]
  command = require './methods/' + name
  for name, value of command
    afs[name] = value
