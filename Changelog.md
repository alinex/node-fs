Version changes
=================================================

The following list gives a short overview about what is changed between
individual versions:

Version 3.0.3 (2016-09-29)
-------------------------------------------------
- Update graceful-fs@4.1.9, alinex-builder@2.3.8, posix@4.1.1, moment@2.15.1
- Optimize debug calls.
- Updated ignore files.
- Update travis.
- Update travis.
- Better filter performance if checking exclude before include.

Version 3.0.2 (2016-08-18)
-------------------------------------------------
- Fix copy target calculation.

Version 3.0.1 (2016-08-18)
-------------------------------------------------
- Fix empty dir in copy() handling.
- Removed unneccessary directory creation.
- Faster skip path also if skip through includes.

Version 3.0.0 (2016-08-18)
-------------------------------------------------
Breaking change of options array.

- Fix copy to throw error if already existing.
- Made chown and chmod capable of find and allow user/group names.
- Reworked asynchroneous move.
- Updated Readme.
- Finished restructuring of remover() methods.
- Optimize remove() performance by working in one run.
- Finished async remove.
- Fix documentation links.
- Start reworking remove and move methods.
- Fix examples to new filter rule format.
- Put filter options into subgrop named 'filter'.
- Update alinex-builder@2.3.6
- Update docs for copy method.
- Optimize documentation of find() method.
- Use posix instead of own user/group reader.
- Update docs.
- Optimize find to work with async queue correctly respecting the given parallel limit.
- Add support for parallel limit in copy method.
- Fix matching of concrete file.
- Support parallel setting through options.
- Allow multiple filter rule sets to be given.
- Move helper methods into own folder.
- Add examples for filter use.
- Fix documentation.
- Rework documentation of filter rules.
- Add error to documentation.
- Fix for multi include/exclude.
- Allow multiple exclude/include patterns to be checked.

Version 2.0.7 (2016-08-10)
-------------------------------------------------
- Allow all tests to run.
- Don't throw but return error in async mkdirs call.
- Upgraded async@2.0.1, graceful-fs@4.1.5, minimatch@3.0.3, alinex-builder@2.3.5
- Add maxnum parameter to mkdirs.
- Fix mkdirs timing bug in parallel use.
- Allow retries in mkdir.
- Rename internal subfolder.
- Small typo fix.
- Move documentation into separate methods.
- Updated documentation.
- Move examples to temp... methods.
- More explanations for file stat results.
- Fix tests to work with new structure.
- Fix some documentation problems.
- Converted the last methods, too.
- Convert npmbin(), tempdir() and tempfile()
- Restructer move()
- Restructure copy(), remove().
- Move stat, mkdirs, find to new internal structure.
- Start restructuring docu and internal code structure of fs package.
- Upgraded async@2.0.1, graceful-fs@4.1.5, alinex-builder@2.3.4, memoizee@0.4.1.

Version 2.0.6 (2016-07-20)
-------------------------------------------------
- optimize include check to always scheck for exclude on fullname match, too.

Version 2.0.5 (2016-07-20)
-------------------------------------------------
- Hot fix in file pattern search.

Version 2.0.4 (2016-07-20)
-------------------------------------------------
- Fix subfile name calculation based on depth.
- Upgrade alinex-builder@2.3.1, memoizee@0.4.1, async@2.0.0
- Fixed subpath for path check on parent directory (depth = 0).
- Remove lazy option and do this for path exclude checks automatically.
- Rename links to Alinex Namespace.
- Add copyright sign.

Version 2.0.3 (2016-07-08)
-------------------------------------------------
Replace defect build.

- Update alinex-builder@2.1.14
- Fix bug in pattern checking of root element.
- Upgrade chrono-node@1.2.4, graceful-fs@4.1.4, minimatch@3.0.2, alinex-builder@2.1.13, moment@2.14.1

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

