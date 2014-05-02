chai = require 'chai'
expect = chai.expect
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
  ]

  check = (options, list, cb) ->
    async.filter files, (file, cb) ->
      filter.async file, options, cb
    , (result) ->
#      console.log "check pattern", options, "with result: #{result}"
      expect(result, util.inspect options).to.deep.equal list
      cb()

  describe.only "asynchronous", ->

    it "should match start using asterix", (cb) ->
      async.series [
        (cb) -> check { include: 'a*' }, ['a', 'abc', 'abd', 'abe'], cb
        (cb) -> check { include: 'c*' }, ['c', 'ca', 'cb', 'bdir/cfile'], cb
        (cb) -> check { include: 'X*' }, [], cb
      ], cb
#?
    it "should match directories only", (cb) ->
      async.series [
        (cb) -> check { include: 'b*/' }, ['bdir/'], cb
      ], cb

    it "should match all", (cb) ->
      async.series [
        (cb) -> check { include: '*' }, files, cb
        (cb) -> check { include: '**' }, files, cb
      ], cb

    it "should match character classes", (cb) ->
      async.series [
        (cb) -> check { include: '[a-c]b*' }, ['abc', 'abd', 'abe', 'bb', 'cb'], cb
        (cb) -> check { include: '[a-y]*[^c]' }, ['abd', 'abe', 'bb', 'bcd', 'ca', 'cb', 'dd', 'de', 'bdir/', 'bdir/cfile'], cb
        (cb) -> check { include: 'a*[^c]' }, ['abd', 'abe'], cb
        (cb) -> check { include: 'z[][-]' }, ['z[', 'z]', 'z-'], cb
        (cb) -> check { include: '[^a-cz]*' }, ['d', 'dd', 'de'], cb
      ], cb




    it "should match with special chars", (cb) ->
      async.series [
        (cb) -> check { include: 'z\\*' }, ['z*'], cb
        (cb) -> check { include: 'z\\?' }, ['z?'], cb
        (cb) -> check { include: 'z\\[' }, ['z['], cb
      ], cb
