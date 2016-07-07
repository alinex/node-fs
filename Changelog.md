Version changes
=================================================

The following list gives a short overview about what is changed between
individual versions:

Version 2.0.2 (2016-07-07)
-------------------------------------------------
- Upgrade memoizee@3.0.0
- Check pattern against subpath only.

Version 2.0.1 (2016-05-03)
-------------------------------------------------
- Add documentation.
- Add chowns and chmods method.
- Add chowns method.
- Fixed touch, extended coverage.
- Remove node v6 bacause subpackages not supported there.
- Added documentation for touch.
- Change examples to coffee script.
- Add tests for touch.
- Fixed filter tests to work with new async module.
- Add touch functionality.
- Upgrade async and builder package.
- Added tempfile methods.
- Fix bug in tempdirSync.
- Fix bug in npmbinSync.
- Updated chrono, moment, memoizeem, builder.
- Fixed general link in README.

Version 2.0.0 (2016-02-04)
-------------------------------------------------
- 

Version 1.0.0 (2016-02-04)
-------------------------------------------------
- Remove error package and upgraded to use alinex-builder.
- Remove deprecation warnings.
- Don't throw error on deletion of missing file node.
- updated ignore files.
- Fixed style of test cases.
- Fixed lint warnings in code.
- Updated meta data of package and travis build versions.
- Updated third party modules.
- Made time filters more clear in description.
- Updated insstall documentation.
- Made badge links npm compatible in documentation.
- Use special debug output in find.
- Fixed creation with default name if process has path as title.
- Merge branch 'master' of https://github.com/alinex/node-fs
- Updated changelog.
- Added documentation for the lazy option.
- Merge pull request #3 from amazo/master
- fix bug
- Add lazy option
- fix bug
- Ignore children find if parent was excluded
- Default for prefix in tempdir() is proccess title.

Version 0.2.1 (2015-02-14)
-------------------------------------------------
- Merge branch 'master' of https://github.com/alinex/node-fs
- Added information for version 0.2.0
- Added ignoreErrors option.
- Update dependent packages.

Version 0.1.10 (2015-02-03)
-------------------------------------------------
- Bug fixed: complete filename without asterix will now match also.

Version 0.1.9 (2015-01-26)
-------------------------------------------------
- Fixed bug in tempdirSync() call.
- Added tempdir() method.
- Optimized stat calls with dereferences.
- Updated depending modules.
- Fixed package.json version notation.
- Fixed npmignor file.

Version 0.1.8 (2014-09-27)
-------------------------------------------------
- Upgraded alinex-make module.

Version 0.1.7 (2014-09-17)
-------------------------------------------------
- Reformat minimatch version check.
- Updated to debug 2.0.0
- Fixed calls to new make tool.
- Updated alinex-make to version 0.3 for development.

Version 0.1.6 (2014-08-08)
-------------------------------------------------
- Updated minimatch version.
- Added description of type filter.
- Merge branch 'master' of https://github.com/alinex/node-fs
- Added the top features to documentation.
- Small wording fixes in documentation.
- Merge branch 'master' of https://github.com/alinex/node-fs
- Merge branch 'master' of https://github.com/alinex/node-fs
- Always return find result in alphabetical order.
- Fixed documentation links to filter description.
- Removed unused package alinex-error.
- Updated submodules graceful-fs and debug.
- Run mocha on lib folder.

Version 0.1.5 (2014-07-05)
-------------------------------------------------
- Fixed broken code in empty options check.

Version 0.1.4 (2014-06-29)
-------------------------------------------------
- Fixed bug in which directory should be created to late.
- Optimized filter to only run then options are given.
- Updated minimatch module to allow 0.3 version.
- Changed move tests to work on lib for coverage.

Version 0.1.3 (2014-05-12)
-------------------------------------------------
- Restructure main collecting single methods.
- Added search in global installations to npmbin.

Version 0.1.2 (2014-05-11)
-------------------------------------------------
- Added multiple debug messages and fixed move tests.
- Added tests for move.
- Added options support to the move method and usage documentation.
- Added methods to move files or directories.
- Don't touch the original fs so it may be used unchanged.

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

