###
API Usage
=================================================
For the [standard](https://nodejs.org/api/fs.html) node.js functions everything is
the same as far as not listed below.


Extended Functionality
----------------------------------------------------
All the extended functions use the same naming convention as the node core, making
the use nearly natural. And you can still use the native Node.js methods, also.

Some of the **native methods** are slightly changed:
- [stat/lstat](stat.coffee) - file stat retrieval (with caching)

**Additional methods**:
- [mkdirs](mkdirs.coffee) - recursive create depth directory with it's parents
- [npmdir](npmdir.coffee) - find binary in NPM path
- [tempdir](tempdir.coffee) - create temporary directory
- [tempfile](tempfile.coffee) - create temporary file

Working on **multiple files** using filter rules:
- [find](find.coffee) - search for files or directories
- [copy](copy.coffee) - copy file, directory or selection
- [move](move.coffee) - move file, directory or selection
- [remove](remove.coffee) - remove file, directory or selection
- [touch](touch.coffee) - touch file
- [chowns](chowns.coffee) - change ownership of file, directory or selection
- [chmods](chmods.coffee) - change access rights of file, directory or selection

Most methods use an options object which can specify how it works. The options are
based on the tree serach and {@link filter.coffee filter specification}.
Some also have their own options described within the method itself.


Async vs Sync
-------------------------------------------------
All this methods may be called asynchroneous or synchroneous.

Because the decision of using asynchroneous or synchroneous methods is based on
blocking IO as far as possible you should better use this methods async and do some
other things in parallel.

Only if your could is synchroneous anyway and you can't do other things while the
IO works the use of the corresponding `...Sync()` methods are easier to add. It will
also be more readable in major to guys not so involved in async programming.

Asynchroneous call:

``` coffee
fs.find '/tmp/some/directory', {include: '*.jpg'}, (err, list) ->
  return console.error err.message if err
  console.log "Found " + list.length + " images."
  # do something with list
```

Synchroneous call:

``` coffee
try
  list = fs.findSync '/tmp/some/directory', {include: '*.jpg'}
catch error
  return console.error error.message
console.log "Found " + list.length + " images."
# do something with list
```

Differences are always the same:
- async version needs a callback as last parameter
- error and result will be retrieved in callback for async version
- the sync version may throw an error and return the result directly

Because the preferred way is to use asynchroneous calls this is also shown in all
the examples.


Tree Search
---------------------------------------------------------
A lot of the extended methods allow traversing the directory tree and checking the
found entries through the {@link filter.coffee filter} options.

For file parsing the following options may be specified:
- {@link filter.coffee}
- `dereference` - `Boolean` don't use the symbolic link as an entry but dereference
  it and check the target of it and go into it (default: `false`)
- `ignoreErrors` - `Boolean` ignore dead symlinks otherwise an `Error` is created
  (default: `false`)
- `parallel` - `Integer` number of maximum parallel calls in asynchronous run
  (defaults to half of open files limit per process on the system)

For all other look into the method description.



Debugging
---------------------------------------------------------
This module uses the {@link debug} module so you may anytime call your app with
the environment setting `DEBUG=fs:*` but keep in mind that this will output a
lot of information. So better use the concrete setting in each module. Most have one
defined with their name:

    DEBUG=fs:*      -> complete fs package
    DEBUG=fs:copy   -> only copy method
###


# Node Modules
# -------------------------------------------------
fs = require 'graceful-fs'


# Clone original fs
# -------------------------------------------------
afs = module.exports = {}
for name, value of fs
  afs[name] = value


# Add extended functionality
# -------------------------------------------------
for name in [
  'stat'
  'mkdirs', 'find', 'copy', 'remove', 'move'
  'npmbin', 'tempdir', 'tempfile', 'touch'
  'chowns', 'chmods'
]
  command = require './method/' + name
  for name, value of command
    afs[name] = value
