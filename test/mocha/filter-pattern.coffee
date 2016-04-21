chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###
async = require 'async'
util = require 'util'

# Only use alinex-error to detect errors, it makes messy output with the normal
# mocha error output.
#require('alinex-error').install()

describe "Pattern matching filter", ->

  filter = require '../../src/filter'

  # Tests based on
  # -------------------------------------------------------
  # http://www.bashcookbook.com/bashinfo/source/bash-1.14.7/tests/glob-test

  files = [
    'a', 'b', 'c', 'd'
    'abc', 'abd', 'abe', 'bb', 'bcd'
    'ca', 'cb'
    'dd', 'de'
    'bdir/', 'bdir/cfile',
    'z*', 'z?', 'z[', 'z]', 'z-'
    'z1z', 'z2z'
  ]

  check = (options, list, cb) ->
    async.filter files, (file, cb) ->
      filter.async file, 0, options, cb
    , (result) ->
#      console.log "check pattern", options, "with result: #{result}"
      expect(result, util.inspect options).to.deep.equal list
      cb()

  checkSync = (options, list) ->
    result = []
    for file in files
      result.push file if filter.sync file, 0, options
#    console.log "check pattern", options, "with result: #{result}"
    expect(result, util.inspect options).to.deep.equal list

  describe "asynchronous", ->

    it "should match start using asterix", (cb) ->
      async.series [
        (cb) -> check {include: 'a*'}, ['a', 'abc', 'abd', 'abe'], cb
        (cb) -> check {include: 'c*'}, ['c', 'ca', 'cb', 'bdir/cfile'], cb
        (cb) -> check {include: 'X*'}, [], cb
      ], cb

    it "should match start using questionmark", (cb) ->
      async.series [
        (cb) -> check {include: 'a?c'}, ['abc'], cb
        (cb) -> check {include: '?'}, ['a', 'b', 'c', 'd'], cb
      ], cb

    it "should match directories only", (cb) ->
      async.series [
        (cb) -> check {include: 'b*/'}, ['bdir/'], cb
      ], cb

    it "should match all", (cb) ->
      async.series [
        (cb) -> check {include: '*'}, files, cb
        (cb) -> check {include: '**'}, files, cb
      ], cb

    it "should match character groups", (cb) ->
      async.series [
        (cb) -> check {include: '[a-c]b*'}, ['abc', 'abd', 'abe', 'bb', 'cb'], cb
        (cb) -> check {include: '[a-y]*[^c]'},
          ['abd', 'abe', 'bb', 'bcd', 'ca', 'cb', 'dd', 'de', 'bdir/', 'bdir/cfile'], cb
        (cb) -> check {include: 'a*[^c]'}, ['abd', 'abe'], cb
        (cb) -> check {include: 'z[][-]'}, ['z[', 'z]', 'z-'], cb
        (cb) -> check {include: '[^a-cz]*'}, ['d', 'dd', 'de'], cb
      ], cb

    it "should allow brace expansion", (cb) ->
      async.series [
        (cb) -> check {include: 'ab{c,d}'}, ['abc', 'abd'], cb
        (cb) -> check {include: 'z{1..3}z'}, ['z1z', 'z2z'], cb
      ], cb

    it "should allow extended globbing", (cb) ->
      async.series [
        (cb) -> check {include: 'b?(b)'}, ['b', 'bb'], cb
        (cb) -> check {include: '*(b)'}, ['b', 'bb'], cb
        (cb) -> check {include: '+(b)'}, ['b', 'bb'], cb
        (cb) -> check {include: '@(ab*|bc*)'}, ['abc', 'abd', 'abe', 'bcd'], cb
      ], cb

    it "should match with special chars", (cb) ->
      async.series [
        (cb) -> check {include: 'z\\*'}, ['z*'], cb
        (cb) -> check {include: 'z\\?'}, ['z?'], cb
        (cb) -> check {include: 'z\\['}, ['z['], cb
      ], cb

    it "should match using excludes", (cb) ->
      async.series [
        (cb) -> check {exclude: '[bcdz]*'}, ['a', 'abc', 'abd', 'abe'], cb
      ], cb

    it "should match using includes and excludes", (cb) ->
      async.series [
        (cb) -> check {include: 'a*', exclude: '*c'}, ['a', 'abd', 'abe'], cb
      ], cb

    it "should match start using regexp", (cb) ->
      async.series [
        (cb) -> check {include: /^a/}, ['a', 'abc', 'abd', 'abe'], cb
        (cb) -> check {include: /^c/}, ['c', 'ca', 'cb'], cb
        (cb) -> check {include: /^X/}, [], cb
        (cb) -> check {exclude: /^[bcdz]/}, ['a', 'abc', 'abd', 'abe'], cb
        (cb) -> check {include: /^a/, exclude: /c$/}, ['a', 'abd', 'abe'], cb
      ], cb

  describe "synchronous", ->

    it "should match start using asterix", ->
      checkSync {include: 'a*'}, ['a', 'abc', 'abd', 'abe']
      checkSync {include: 'c*'}, ['c', 'ca', 'cb', 'bdir/cfile']
      checkSync {include: 'X*'}, []

    it "should match start using questionmark", ->
      checkSync {include: 'a?c'}, ['abc']
      checkSync {include: '?'}, ['a', 'b', 'c', 'd']

    it "should match directories only", ->
      checkSync {include: 'b*/'}, ['bdir/']

    it "should match all", ->
      checkSync {include: '*'}, files
      checkSync {include: '**'}, files

    it "should match character groups", ->
      checkSync {include: '[a-c]b*'}, ['abc', 'abd', 'abe', 'bb', 'cb']
      checkSync {include: '[a-y]*[^c]'},
        ['abd', 'abe', 'bb', 'bcd', 'ca', 'cb', 'dd', 'de', 'bdir/', 'bdir/cfile']
      checkSync {include: 'a*[^c]'}, ['abd', 'abe']
      checkSync {include: 'z[][-]'}, ['z[', 'z]', 'z-']
      checkSync {include: '[^a-cz]*'}, ['d', 'dd', 'de']

    it "should allow brace expansion", ->
      checkSync {include: 'ab{c,d}'}, ['abc', 'abd']
      checkSync {include: 'z{1..3}z'}, ['z1z', 'z2z']

    it "should allow extended globbing", ->
      checkSync {include: 'b?(b)'}, ['b', 'bb']
      checkSync {include: '*(b)'}, ['b', 'bb']
      checkSync {include: '+(b)'}, ['b', 'bb']
      checkSync {include: '@(ab*|bc*)'}, ['abc', 'abd', 'abe', 'bcd']

    it "should match with special chars", ->
      checkSync {include: 'z\\*'}, ['z*']
      checkSync {include: 'z\\?'}, ['z?']
      checkSync {include: 'z\\['}, ['z[']

    it "should match using excludes", ->
      checkSync {exclude: '[bcdz]*'}, ['a', 'abc', 'abd', 'abe']

    it "should match using includes and excludes", ->
      checkSync {include: 'a*', exclude: '*c'}, ['a', 'abd', 'abe']

    it "should match start using regexp", ->
      checkSync {include: /^a/}, ['a', 'abc', 'abd', 'abe']
      checkSync {include: /^c/}, ['c', 'ca', 'cb']
      checkSync {include: /^X/}, []
      checkSync {exclude: /^[bcdz]/}, ['a', 'abc', 'abd', 'abe']
      checkSync {include: /^a/, exclude: /c$/}, ['a', 'abd', 'abe']
