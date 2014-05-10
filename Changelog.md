Version changes
=================================================

The following list gives a short overview about what is changed between
individual versions:

Version 0.1.1 (2014-05-09)
-------------------------------------------------
- Added ignore and overwrite options to copy method.

Version 0.1.0 (2014-05-08)
-------------------------------------------------
- Adding the npmbin utility to search for binaries in node_modules.
- Add debug calls to copy and remove.
- Finished tests.
- Don't use POSIX because not properly supported on Mac.
- Finishing owner filter and adding more tests.
- Added time filter.
- Added RegExp matching to include/exclude patterns.
- Extend filters with type and size filter.
- Changed tests to work on lib folder.

Version 0.0.3 (2014-05-06)
-------------------------------------------------
- Fixed code and completed tests for find, copy and remove methods.
- Added more tests to filter and find methods.
- Start reworking filter to support depth.
- Add caching to fs.lstat methods, remove own implementation.
- Add min and max depth checks to find.
- Added filter methods to remove and copy commands.
- Add synchronous filter method attached to find.
- Completed async pattern flter tests.
- Extended pattern matches.
- Fixed bug in mocha tests on calling the source coffee.
- Added basic filter methods to find.

Version 0.0.2 (2014-04-29)
-------------------------------------------------
- Keep permission and time on copy.
- Added synchronous copy method.
- Restructured remove, find, copy to use options.
- Rename meta to lstat method.
- Restructuring of modules.
- Added initial meta module with optimized lstat method.
- Add rudimental find method.
- Based on graceful-fs for more stable file operations.
- Added initial copy method.
- Small code optimization.
- Fixed remove methods on MacOSX.
- check travis to coveralls
- try coveralls in verbose mode
- try coveralls in verbose mode
- fixed travis token for coveralls

Version 0.0.1 (2014-04-23)
-------------------------------------------------
- Added methods to remove non-empty directories.
- Moved mkdirs function into extra module.
- Added synchronous version of mkdirs.
- Fixed bug in mkdirs then multiple directories have to be created.
- Added some unit test for makedirs.
- Changed tests to use alinex-make.
- Base on nodes fs module. Extend with mkdirs method.

