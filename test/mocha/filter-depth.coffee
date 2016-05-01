chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###
async = require 'async'
util = require 'util'

describe "Filter file structure depth", ->

  filter = require '../../src/filter'

  files = [
    'a', 'b', 'c', 'd', 'dir1'
    'dir1/abc', 'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
    'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
    'dir1/dir2/dir3/dd', 'dir1/dir2/dir3/de'
  ]

  check = (options, list, cb) ->
    async.filter files, (file, cb) ->
      parts = file.split /\//
      filter.async file, (parts.length-1), options, cb
    , (err, result) ->
#      console.log "check pattern", options, "with result: #{result}"
      expect(result, util.inspect options).to.deep.equal list
      cb()

  checkSync = (options, list) ->
    result = []
    for file in files
      parts = file.split /\//
      result.push file if filter.sync file, (parts.length-1), options
#    console.log "check pattern", options, "with result: #{result}"
    expect(result, util.inspect options).to.deep.equal list

  describe "asynchronous", ->

    it "should match all", (cb) ->
      async.series [
        (cb) -> check {}, files, cb
        (cb) -> check {mindepth: 0}, files, cb
        (cb) -> check {maxdepth: 100}, files, cb
      ], cb

    it "should start at defined level", (cb) ->
      async.series [
        (cb) -> check {mindepth: 1}, [
          'dir1/abc', 'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
          'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
          'dir1/dir2/dir3/dd', 'dir1/dir2/dir3/de'
        ], cb
        (cb) -> check {mindepth: 2}, [
          'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
          'dir1/dir2/dir3/dd', 'dir1/dir2/dir3/de'
        ], cb
        (cb) -> check {mindepth: 3}, [
          'dir1/dir2/dir3/dd', 'dir1/dir2/dir3/de'
        ], cb
        (cb) -> check {mindepth: 4}, [], cb
      ], cb

    it "should end at defined level", (cb) ->
      async.series [
        (cb) -> check {maxdepth: 3}, [
          'a', 'b', 'c', 'd', 'dir1'
          'dir1/abc', 'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
          'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
          'dir1/dir2/dir3/dd', 'dir1/dir2/dir3/de'
        ], cb
        (cb) -> check {maxdepth: 2}, [
          'a', 'b', 'c', 'd', 'dir1'
          'dir1/abc', 'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
          'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
        ], cb
        (cb) -> check {maxdepth: 1}, [
          'a', 'b', 'c', 'd', 'dir1', 'dir1/abc'
          'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
        ], cb
        (cb) -> check {maxdepth: 0}, [
          'a', 'b', 'c', 'd', 'dir1'
        ], cb
      ], cb

    it "should extract specific level", (cb) ->
      async.series [
        (cb) -> check {mindepth: 0, maxdepth: 0}, [
          'a', 'b', 'c', 'd', 'dir1'
        ], cb
        (cb) -> check {mindepth: 1, maxdepth: 1}, [
          'dir1/abc', 'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
        ], cb
        (cb) -> check {mindepth: 2, maxdepth: 2}, [
          'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
        ], cb
        (cb) -> check {mindepth: 3, maxdepth: 3}, [
          'dir1/dir2/dir3/dd', 'dir1/dir2/dir3/de'
        ], cb
        (cb) -> check {mindepth: 1, maxdepth: 2}, [
          'dir1/abc', 'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
          'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
        ], cb
      ], cb

  describe "synchronous", ->

    it "should match all", ->
      checkSync {}, files
      checkSync {mindepth: 0}, files
      checkSync {maxdepth: 100}, files

    it "should start at defined level", ->
      checkSync {mindepth: 1}, [
        'dir1/abc', 'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
        'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
        'dir1/dir2/dir3/dd', 'dir1/dir2/dir3/de'
      ]
      checkSync {mindepth: 2}, [
        'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
        'dir1/dir2/dir3/dd', 'dir1/dir2/dir3/de'
      ]
      checkSync {mindepth: 3}, [
        'dir1/dir2/dir3/dd', 'dir1/dir2/dir3/de'
      ]
      checkSync {mindepth: 4}, []

    it "should end at defined level", ->
      checkSync {maxdepth: 3}, [
        'a', 'b', 'c', 'd', 'dir1'
        'dir1/abc', 'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
        'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
        'dir1/dir2/dir3/dd', 'dir1/dir2/dir3/de'
      ]
      checkSync {maxdepth: 2}, [
        'a', 'b', 'c', 'd', 'dir1'
        'dir1/abc', 'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
        'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
      ]
      checkSync {maxdepth: 1}, [
        'a', 'b', 'c', 'd', 'dir1', 'dir1/abc'
        'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
      ]
      checkSync {maxdepth: 0}, [
        'a', 'b', 'c', 'd', 'dir1'
      ]

    it "should extract specific level", ->
      checkSync {mindepth: 0, maxdepth: 0}, [
        'a', 'b', 'c', 'd', 'dir1'
      ]
      checkSync {mindepth: 1, maxdepth: 1}, [
        'dir1/abc', 'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
      ]
      checkSync {mindepth: 2, maxdepth: 2}, [
        'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
      ]
      checkSync {mindepth: 3, maxdepth: 3}, [
        'dir1/dir2/dir3/dd', 'dir1/dir2/dir3/de'
      ]
      checkSync {mindepth: 1, maxdepth: 2}, [
        'dir1/abc', 'dir1/abd', 'dir1/abe', 'dir1/bb', 'dir1/bcd', 'dir1/dir2'
        'dir1/dir2/ca', 'dir1/dir2/cb', 'dir1/dir2/dir3'
      ]
