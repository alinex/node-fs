Package: alinex-fs
=================================================

[![Build Status] (https://travis-ci.org/alinex/node-fs.svg?branch=master)](https://travis-ci.org/alinex/node-fs)
[![Coverage Status] (https://coveralls.io/repos/alinex/node-fs/badge.png?branch=master)](https://coveralls.io/r/alinex/node-fs?branch=master)
[![Dependency Status] (https://gemnasium.com/alinex/node-fs.png)](https://gemnasium.com/alinex/node-fs)

Like some other packages this module adds some functions to the nodes fs package.
It's design as a drop-in replacement.


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
and the following extended functions

* [mkdirs](#mkdirs) and [mkdirsSync](#mkdirssync)
  to make directories like needed (including parent ones)

### mkdirs


### mkdirsSync


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
