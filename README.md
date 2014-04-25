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
* [remove](#remove) and [removeSync](#removesync)
  to remove a file entry with all it's children, if existing

Like you see all the extended functions use the same naming convention as the
node core, making the use nearly natural.

But you can still use the native Node.js methods, also.


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
      console.log("Directory now exists!")
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
      console.log("Directory now exists!")
    } catch (err) {
      return console.error(err);
    }

### remove

This method will remove the given `path` entry and if it is a directory it
will also remove any containing data.

__Arguments:__

* `path`
  File or directory to be removed.
* `callback(err, removed)`
  The callback will be called just if an error occurred. It returns the
  file entry which was removed, if any.

__Example:__

    var fs = require('alinex-fs');
    fs.remove('/tmp/some/directory', function(err, removed) {
      if (err) return console.error(err);
      if (removed) console.log("Directory '"+removed+"' was removed with all it's contents.");
      console.log("Directory no longer exists!")
    });

### removeSync

This will do the same as `remove` but in an synchronous version.

__Arguments:__

* `path`
  File or directory to create if not existing.

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
      console.log("Directory no longer exists!")
    } catch (err) {
      return console.error(err);
    }


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
