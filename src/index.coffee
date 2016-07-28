###
API Usage
=================================================
For the [standard](http://nodejs.org/api/fs.html) node.js functions everything is
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
- [mkdirs](mkdirs.coffee) -
- [find](find.coffee) -
- [copy](copy.coffee) -
- [remove](remove.coffee) -
- [move](move.coffee) -
- [npmdir](npmdir.coffee) -
- [tempdir](tempdir.coffee) -
- [tempfile](tempfile.coffee) -
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
  command = require './' + name
  for name, value of command
    afs[name] = value
