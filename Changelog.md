Version changes
=================================================

The following list gives a short overview about what is changed between
individual versions:

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

