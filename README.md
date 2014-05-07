Package: alinex-fs
=================================================

[![Build Status] (https://travis-ci.org/alinex/node-fs.svg?branch=master)](https://travis-ci.org/alinex/node-fs)
[![Coverage Status] (https://coveralls.io/repos/alinex/node-fs/badge.png?branch=master)](https://coveralls.io/r/alinex/node-fs?branch=master)
[![Dependency Status] (https://gemnasium.com/alinex/node-fs.png)](https://gemnasium.com/alinex/node-fs)

Like some other packages this module adds some functions to the nodes fs package.
It's design as a drop-in replacement. It uses also
[graceful-fs](https://github.com/isaacs/node-graceful-fs)
to normalize behavior across different platforms and environments, and to make filesystem access more resilient to errors.

It is one of the modules of the [Alinex Universe](http://alinex.github.io/node-alinex)
following the code standards defined there.


Install
-------------------------------------------------

The easiest way is to let npm add the module directly:

    > npm install alinex-fs --save

[![NPM](https://nodei.co/npm/alinex-fs.png?downloads=true&stars=true)](https://nodei.co/npm/alinex-fs/)


Usage
-------------------------------------------------

To use this enhanced filesystem library change your require line from:

    var fs = require('fs');

to the following:

    var fs = require('alinex-fs');

After this you may use the [standard functions](http://nodejs.org/api/fs.html)
and the following extended functions:

* [mkdirs](#mkdirs) and [mkdirsSync](#mkdirssync)
  to make directories like needed (including parent ones)
* [find](#find) and [findSync](#findsync)
  to get a list of files or directories
* [copy](#copy) and [copySync](#copysync)
  to deep copy directories with files
* [remove](#remove) and [removeSync](#removesync)
  to remove a file entry with all it's children, if existing

The methods `find`, `copy` and `remove` supports multiple options to filter the
files they work on.

Like you see all the extended functions use the same naming convention as the
node core, making the use nearly natural.

But you can still use the native Node.js methods, also. Some of the native
methods are slightly changed:

* `stat` and `statSync` will now use a short caching for performance reasons
* `lstat` and `lstatSync` will now use a short caching for performance reasons


### mkdirs

This method is used to create directories recursively if they don't exist.
That means if the parent directory didn't exist it will also be created, if
possible.

__Arguments:__

* `directory`
  Directory to create if not existing.
* `mode` (optional)
  Mode setting defaults to process's file mode creation mask.
* `callback(err, made)`
  The callback will be called just if an error occurred. It returns the first
  directory that had to be created, if any.

__Example:__

    var fs = require('alinex-fs');
    fs.mkdirs('/tmp/some/directory', function(err, made) {
      if (err) return console.error(err);
      if (made) console.log("Directory starting from '"+made+"' was created.");
      console.log("Directory now exists!");
    });

### mkdirsSync

This will do the same as `mkdirs` but in an synchronous version.

__Arguments:__

* `directory`
  Directory to create if not existing.
* `mode` (optional)
  Mode setting defaults to process's file mode creation mask.

__Return:__

* `made`
  Returns the directory that had to be created, if any.

__Throw:__

* `Error`
  If anything out of order happened.

__Example:__

    var fs = require('alinex-fs');
    try {
      made = fs.mkdirsSync('/tmp/some/directory');
      if (made) console.log("Directory starting from '"+made+"' was created.");
      console.log("Directory now exists!");
    } catch (err) {
      return console.error(err);
    }

### find

List files within directory matching specific options.

__Arguments:__

* `source`
  Path to be searched.
* `options`
  Specification of files to find (see [filter](#flter) options).
* `callback(err, list)`
  The callback will be called just if an error occurred. The list of found
  entries will be given.

__Example:__

    var fs = require('alinex-fs');
    fs.find('/tmp/some/directory', { include: '*.jpg' }, function(err, list) {
      if (err) return console.error(err);
      console.log("Found " + list.length + " images.");
      // do something with list
    });

### findSync

List files within directory matching specific options in a synchronous version.

__Arguments:__

* `source`
  Path to be searched.
* `options`
  Specification of files to find

__Return:__

* `list`
  Returns the list of found entries (see [filter](#flter) options).

__Throw:__

* `Error`
  If anything out of order happened.

__Example:__

    var fs = require('alinex-fs');
    try {
      list = fs.findSync('/tmp/some/directory');
      console.log("Found " + list.length + " images.");
      // do something with list
    } catch (err) {
      return console.error(err);
    }

### copy

Copy complete directories in a recursive way.

__Arguments:__

* `source`
  File or directory to be copied.
* `target`
  File or directory to copy to.
* `options`
  Specification of files to find (see [filter](#flter) options).
* `callback(err)`
  The callback will be called just if an error occurred.

__Example:__

    var fs = require('alinex-fs');
    fs.copy('/tmp/some/directory', function(err) {
      if (err) return console.error(err);
      console.log("Directory copied!");
    });

### copySync

Copy complete directories in a recursive way (synchronous).

__Arguments:__

* `source`
  File or directory to be copied.
* `target`
  File or directory to copy to.
* `options`
  Specification of files to find (see [filter](#flter) options).

__Throw:__

* `Error`
  If anything out of order happened.

__Example:__

    var fs = require('alinex-fs');
    fs.copySync('/tmp/some/directory');
    console.log("Directory copied!");

### remove

This method will remove the given `path` entry and if it is a directory it
will also remove any containing data.

__Arguments:__

* `path`
  File or directory to be removed.
* `options`
  Specification of files to remove (see [filter](#flter) options).
* `callback(err, removed)`
  The callback will be called just if an error occurred. It returns the
  file entry which was removed, if any.

__Example:__

    var fs = require('alinex-fs');
    fs.remove('/tmp/some/directory', function(err, removed) {
      if (err) return console.error(err);
      if (removed) console.log("Directory '"+removed+"' was removed with all it's contents.");
      console.log("Directory no longer exists!");
    });

### removeSync

This will do the same as `remove` but in an synchronous version.

__Arguments:__

* `path`
  File or directory to create if not existing.
* `options`
  Specification of files to remove (see [filter](#flter) options).

__Return:__

* `removed`
  Returns the file entry which was removed.

__Throw:__

* `Error`
   If anything out of order happened.

__Example:__

    var fs = require('alinex-fs');
    try {
      made = fs.removeSync('/tmp/some/directory');
      if (made) console.log("Directory '"+made+"' was removed with all it's contents.");
      console.log("Directory no longer exists!");
    } catch (err) {
      return console.error(err);
    }


Filter
-------------------------------------------------

The filter is used to select some of the files based on specific settings.
The filter is given as options array which may have some of the following
specification settings.
Additionally some methods may have special options for filtering.


### File/path matching

This is based on glob expressions like used in unix systems.

The following option entries are used:

- `include` - to specify a inclusion pattern
- `exclude` - to specify an exclusion pattern

All files are matched which are in the include pattern and not in the exclude
pattern. The pattern may be a regular expression or a glob pattern string with
the following specification:

To use one of the special characters `*`, `?` or `[` you have to preceed it with an
backslash.

The patter may contain:

- `?` (not between brackets) matches any single character.
- `*` (not between brackets) matches any string, including the empty string.
- `**` (not between brackets) matches any string and also includes the path separator.

Character groups:

- `[ade]` or `[a-z]` Matches any one of the enclosed characters ranges can be given using a hyphen.
- `[!ade]` or `[!a-z]` negates the search and matches any character not enclosed.
- `[^ade]` or `[^a-z]` negates the search and matches any character not enclosed.

Brace Expansion:

- `{a,b}` will be expanded to `a` or `b`
- `{a,b{c,d}}` stacked to match `a`, `bc` or `bd`
- `{1..3}` will be expanded to `1` or `2` or `3`

Extended globbing is also possible:

- ?(list): Matches zero or one occurrence of the given patterns.
- *(list): Matches zero or more occurrences of the given patterns.
- +(list): Matches one or more occurrences of the given patterns.
- @(list): Matches one of the given patterns.

### Search depth

The search depth specifies in which level of subdirectories the filter will match.
1 means everything in the given directory, 2 one level deeper.

- `mindepth` minimal depth to match
- `maxdepth` maximal depth to match


### Dereferencing

Normally the methods will not go into symbolic links. They will see the symbolic
link as itself. Using the option `dereference: true` this behavior will change
and they will follow the symbolic link and check the path it refers to. This
means that they will also go into referenced directories.


License
-------------------------------------------------

Copyright 2014 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
