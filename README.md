Filesystem (fs): Readme
=================================================

[![GitHub watchers](
  https://img.shields.io/github/watchers/alinex/node-fs.svg?style=social&label=Watch&maxAge=2592000)](
  https://github.com/alinex/node-fs/subscription)
<!-- {.hidden-small} -->
[![GitHub stars](
  https://img.shields.io/github/stars/alinex/node-fs.svg?style=social&label=Star&maxAge=2592000)](
  https://github.com/alinex/node-fs)
[![GitHub forks](
  https://img.shields.io/github/forks/alinex/node-fs.svg?style=social&label=Fork&maxAge=2592000)](
  https://github.com/alinex/node-fs)
<!-- {.hidden-small} -->
<!-- {p:.right} -->

[![npm package](
  https://img.shields.io/npm/v/alinex-fs.svg?maxAge=2592000&label=latest%20version)](
  https://www.npmjs.com/package/alinex-fs)
[![latest version](
  https://img.shields.io/npm/l/alinex-fs.svg?maxAge=2592000)](
  #license)
<!-- {.hidden-small} -->
[![Travis status](
  https://img.shields.io/travis/alinex/node-fs.svg?maxAge=2592000&label=develop)](
  https://travis-ci.org/alinex/node-fs)
[![Coveralls status](
  https://img.shields.io/coveralls/alinex/node-fs.svg?maxAge=2592000)](
  https://coveralls.io/r/alinex/node-fs?branch=master)
[![Gemnasium status](
  https://img.shields.io/gemnasium/alinex/node-fs.svg?maxAge=2592000)](
  https://gemnasium.com/alinex/node-fs)
[![GitHub issues](
  https://img.shields.io/github/issues/alinex/node-fs.svg?maxAge=2592000)](
  https://github.com/alinex/node-fs/issues)
<!-- {.hidden-small} -->


Like some other packages this module adds functions to the node.js fs package.
It's designed as a drop-in replacement. It uses also {@link graceful-fs}
to normalize behavior across different platforms and environments, and to make
filesystem access more resilient to errors.

This package combines features found in a lot of other packages together without
including too much. Most methods are very customizable using options.

- drop in replacement for node's fs module
- powerful find method
- recursive file handling functions
- complete asynchronous and synchronous
- additional methods

> It is one of the modules of the [Alinex Namespace](https://alinex.github.io/code.html)
> following the code standards defined in the [General Docs](https://alinex.github.io/develop).

__Read the complete documentation under
[https://alinex.github.io/node-fs](https://alinex.github.io/node-fs).__
<!-- {p: .hide} -->


Install
-------------------------------------------------

[![NPM](https://nodei.co/npm/alinex-fs.png?downloads=true&downloadRank=true&stars=true)
 ![Downloads](https://nodei.co/npm-dl/alinex-fs.png?months=9&height=3)
](https://www.npmjs.com/package/alinex-fs)

> See the {@link Changelog.md} for a list of changes in recent versions.

The easiest way is to let npm add the module directly to your modules
(from within you node modules directory):

``` sh
npm install alinex-fs --save
```


Usage
-------------------------------------------------

To use this enhanced filesystem library change your require line from:

``` coffee
fs = require 'fs'
```

to the following:

``` coffee
fs = require 'alinex-fs'
```

After this you may use the [standard functions](https://nodejs.org/api/fs.html)
and the following extended functions:

* [mkdirs](#mkdirs) and [mkdirsSync](#mkdirssync)
  to make directories like needed (including parent ones)
* [find](#find) and [findSync](#findsync)
  to get a list of files or directories
* [copy](#copy) and [copySync](#copysync)
  to deep copy directories with files
* [remove](#remove) and [removeSync](#removesync)
  to remove a file entry with all it's children, if existing
* [move](#move) and [moveSync](#movesync)
  to move a file to another position
* [npmbin](#npmbin) and [npmbinSync](#npmbinsync)
  to find a binary in the module or it's parent
* [tempdir](#tempdir) and [tempdirSync](#tempdirsync)
  to create a temporary directory

The methods `find`, `copy` and `remove` supports multiple options to filter the
files they work on.

Like you see all the extended functions use the same naming convention as the
node core, making the use nearly natural.


License
-------------------------------------------------

(C) Copyright 2014-2016 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
