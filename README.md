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
pattern.

The patter may contain:

- A `?` (not between brackets) matches any single character.
- A `*` (not between brackets) matches any string, including the empty string.
- [...]: Matches any one of the enclosed characters.

  A pair of characters separated by a hyphen denotes a range expression; any character that sorts between
              those two characters, inclusive, using the current locale's collating sequence and character set, is matched.  If the first character following  the
              [  is  a  !   or  a ^ then any character not enclosed is matched.  The sorting order of characters in range expressions is determined by the current
              locale and the value of the LC_COLLATE shell variable, if set.  A - may be matched by including it as the first or last character in the set.   A  ]
              may be matched by including it as the first character in the set.

              Within  [  and  ],  character  classes can be specified using the syntax [:class:], where class is one of the following classes defined in the POSIX
              standard:
              alnum alpha ascii blank cntrl digit graph lower print punct space upper word xdigit
              A character class matches any character belonging to that class.  The word character class matches letters, digits, and the character _.

              Within [ and ], an equivalence class can be specified using the syntax [=c=], which matches all  characters  with  the  same  collation  weight  (as
              defined by the current locale) as the character c.

              Within [ and ], the syntax [.symbol.] matches the collating symbol symbol.


Character classes
       An  expression  '[...]' where the first character after the leading '['
       is not an '!' matches a single character, namely any of the  characters
       enclosed  by  the brackets.  The string enclosed by the brackets cannot
       be empty; therefore ']' can be allowed between the  brackets,  provided
       that  it is the first character. (Thus, '[][!]' matches the three char-
       acters '[', ']' and '!'.)

  Ranges
       There is one special convention: two characters separated by '-' denote
       a    range.    (Thus,   '[A-Fa-f0-9]'   is   equivalent   to   '[ABCDE-
       Fabcdef0123456789]'.)  One may include '-' in its  literal  meaning  by
       making  it  the  first  or last character between the brackets.  (Thus,
       '[]-]' matches just the two characters ']' and '-', and '[--0]' matches
       the three characters '-', '.', '0', since '/' cannot be matched.)

  Complementation
       An expression '[!...]' matches a single character, namely any character
       that is not matched by the expression obtained by  removing  the  first
       '!'  from it.  (Thus, '[!]a-]' matches any single character except ']',
       'a' and '-'.)

       One can remove the special meaning of '?', '*'  and  '['  by  preceding
       them  by a backslash, or, in case this is part of a shell command line,
       enclosing them in quotes.  Between brackets these characters stand  for
       themselves.   Thus,  '[[?*\]' matches the four characters '[', '?', '*'
       and '\'.

Globbing is applied on each of the components of a pathname separately.
       A '/' in a pathname cannot be matched by a '?' or '*' wildcard, or by a
       range like '[.-0]'. A range cannot contain an explicit  '/'  character;
       this would lead to a syntax error.

       If  a  filename  starts  with  a  '.',  this  character must be matched
       explicitly.  (Thus, 'rm *' will not remove .profile, and 'tar c *' will
       not archive all your files; 'tar c .' is better.)

Extended globbing as described by the bash man page:

- ?(list): Matches zero or one occurrence of the given patterns.
- *(list): Matches zero or more occurrences of the given patterns.
- +(list): Matches one or more occurrences of the given patterns.
- @(list): Matches one of the given patterns.
- !(list): Matches anything except one of the given patterns.


- Brace Expansion
- Extended glob matching
- "Globstar" ** matching


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
