chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###
async = require 'async'
util = require 'util'
{exec} = require 'child_process'
fs = require 'fs'
moment = require 'moment'

describe "Time filter", ->

  filter = require '../../src/methods/filter'

  files = [
    'test/temp/file1'
    'test/temp/file2'
    'test/temp/dir1'
    'test/temp/dir1/file11'
    'test/temp/dir2'
    'test/temp/dir3'
  ]

  beforeEach (cb) ->
    exec 'mkdir -p test/temp/dir1', ->
      exec 'mkdir -p test/temp/dir2', ->
        exec 'touch test/temp/file1', ->
          exec 'touch test/temp/file2', ->
            exec 'touch test/temp/dir1/file11', ->
              exec 'ln -s dir1 test/temp/dir3', ->
                day1 = moment().subtract(1, 'day').unix()
                day3 = moment().subtract(3, 'days').unix()
                day5 = moment().subtract(5, 'days').unix()
                fs.utimesSync 'test/temp/file1', day1, day5
                fs.utimesSync 'test/temp/file2', day1, day3
                fs.utimesSync 'test/temp/dir1/file11', day3, day3
                setTimeout cb, 500

  afterEach (cb) ->
    fs.exists 'test/temp', (exists) ->
      return cb() unless exists
      exec 'rm -r test/temp', cb

  check = (options, list, cb) ->
    async.filter files, (file, cb) ->
      filter.filter file, 0, options, (success) -> cb null, success
    , (err, result) ->
#      console.log "check pattern", options, "with result: #{result}"
      expect(result, util.inspect options).to.deep.equal list
      cb()

  checkSync = (options, list) ->
    result = []
    for file in files
      result.push file if filter.filterSync file, 0, options
#    console.log "check pattern", options, "with result: #{result}"
    expect(result, util.inspect options).to.deep.equal list

  describe "asynchronous", ->

    it "should find modified after", (cb) ->
      async.series [
        (cb) -> check
          modifiedAfter: moment().subtract(6, 'days').unix()
        , files, cb
        (cb) -> check
          modifiedAfter: '6 days ago'
        , files, cb
        (cb) -> check
          modifiedAfter: '4 days ago'
        , [
          'test/temp/file2'
          'test/temp/dir1', 'test/temp/dir1/file11'
          'test/temp/dir2', 'test/temp/dir3'
        ], cb
        (cb) -> check
          modifiedAfter: '2 days ago'
        , [
          'test/temp/dir1'
          'test/temp/dir2', 'test/temp/dir3'
        ], cb
      ], cb

    it "should find modified before", (cb) ->
      async.series [
        (cb) -> check
          modifiedBefore: moment().add(1, 'hour').unix()
        , files, cb
        (cb) -> check
          modifiedBefore: 'tomorrow'
        , files, cb
        (cb) -> check
          modifiedBefore: '2 days ago'
        , [
          'test/temp/file1', 'test/temp/file2'
          'test/temp/dir1/file11'
        ], cb
        (cb) -> check
          modifiedBefore: '4 days ago'
        , [
          'test/temp/file1'
        ], cb
        (cb) -> check
          modifiedBefore: '6 days ago'
        , [], cb
      ], cb

    it "should find accessed after", (cb) ->
      async.series [
        (cb) -> check
          accessedAfter: moment().subtract(6, 'days').unix()
        , files, cb
        (cb) -> check
          accessedAfter: '4 days ago'
        , files, cb
        (cb) -> check
          accessedAfter: '2 days ago'
        , [
          'test/temp/file1', 'test/temp/file2'
          'test/temp/dir1'
          'test/temp/dir2', 'test/temp/dir3'
        ], cb
        (cb) -> check
          accessedAfter: '0:00'
        , [
          'test/temp/dir1'
          'test/temp/dir2', 'test/temp/dir3'
        ], cb
      ], cb

    it "should find accessed before", (cb) ->
      async.series [
        (cb) -> check
          accessedBefore: moment().add(1, 'hour').unix()
        , files, cb
        (cb) -> check
          accessedBefore: 'tomorrow'
        , files, cb
        (cb) -> check
          accessedBefore: '2 days ago'
        , [
          'test/temp/dir1/file11'
        ], cb
      ], cb

  describe "synchronous", ->

    it "should find modified after", ->
      checkSync
        modifiedAfter: moment().subtract(6, 'days').unix()
      , files
      checkSync
        modifiedAfter: '6 days ago'
      , files
      checkSync
        modifiedAfter: '4 days ago'
      , [
        'test/temp/file2'
        'test/temp/dir1', 'test/temp/dir1/file11'
        'test/temp/dir2', 'test/temp/dir3'
      ]
      checkSync
        modifiedAfter: '2 days ago'
      , [
        'test/temp/dir1'
        'test/temp/dir2', 'test/temp/dir3'
      ]

    it "should find modified before", ->
      checkSync
        modifiedBefore: moment().add(1, 'hour').unix()
      , files
      checkSync
        modifiedBefore: 'tomorrow'
      , files
      checkSync
        modifiedBefore: '2 days ago'
      , [
        'test/temp/file1', 'test/temp/file2'
        'test/temp/dir1/file11'
      ]
      checkSync
        modifiedBefore: '4 days ago'
      , [
        'test/temp/file1'
      ]
      checkSync
        modifiedBefore: '6 days ago'
      , []

    it "should find accessed after", ->
      checkSync
        accessedAfter: moment().subtract(6, 'days').unix()
      , files
      checkSync
        accessedAfter: '4 days ago'
      , files
      checkSync
        accessedAfter: '2 days ago'
      , [
        'test/temp/file1', 'test/temp/file2'
        'test/temp/dir1'
        'test/temp/dir2', 'test/temp/dir3'
      ]
      checkSync
        accessedAfter: '0:00'
      , [
        'test/temp/dir1'
        'test/temp/dir2', 'test/temp/dir3'
      ]

    it "should find accessed before", ->
      checkSync
        accessedBefore: moment().add(1, 'hour').unix()
      , files
      checkSync
        accessedBefore: 'tomorrow'
      , files
      checkSync
        accessedBefore: '2 days ago'
      , [
        'test/temp/dir1/file11'
      ]
