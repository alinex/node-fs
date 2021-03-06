chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###
async = require 'async'
util = require 'util'

describe "Own filter function", ->

  filter = require '../../src/helper/filter'

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
      filter.filter file, 0, {filter: options}, (success) -> cb null, success
    , (err, result) ->
#      console.log "check pattern", options, "with result: #{result}"
      expect(result, util.inspect options).to.deep.equal list
      cb()

  checkSync = (options, list) ->
    result = []
    for file in files
      result.push file if filter.filterSync file, 0, {filter: options}
#    console.log "check pattern", options, "with result: #{result}"
    expect(result, util.inspect options).to.deep.equal list

  describe "asynchronous", ->

    it "should be called", (cb) ->
      check
        test: (file, options, cb) ->
          cb ~file.indexOf 'ab'
      , ['abc', 'abd', 'abe'], cb

  describe "synchronous", ->

    it "should be called", ->
      checkSync
        test: (file) ->
          return ~file.indexOf 'ab'
      , ['abc', 'abd', 'abe']
