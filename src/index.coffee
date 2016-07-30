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
Additional functionalities are:
- [stat/lstat](stat.coffee) - file stat retrieval
- [mkdirs](mkdirs.coffee) - recursive create depth directory with it's parents
- [find](find.coffee) - search for files or directories
- [copy](copy.coffee) - copy file, directory or selection
- [move](move.coffee) - move file, directory or selection
- [remove](remove.coffee) - remove file, directory or selection
- [npmdir](npmdir.coffee) - find binary in NPM path
- [tempdir](tempdir.coffee) - create temporary directory
- [tempfile](tempfile.coffee) - create temporary file
- [touch](touch.coffee) -
- [chowns](chowns.coffee) -
- [chmods](chmods.coffee) -
###

# Add extended functionality
# -------------------------------------------------
for name in [
  'stats'
  'mkdirs', 'find', 'copy', 'remove', 'move'
  'npmbin', 'tempdir', 'tempfile', 'touch'
  'chowns', 'chmods'
]
  command = require './methods/' + name
  for name, value of command
    afs[name] = value
