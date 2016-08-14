chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###
async = require 'async'
util = require 'util'
{exec} = require 'child_process'
fs = require 'fs'

describe "Type filtering", ->

  filter = require '../../src/helper/filter'

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
              exec 'ln -s dir1 test/temp/dir3', cb

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

    it "only list files", (cb) ->
      async.series [
        (cb) ->
          check
            type: 'f'
          , ['test/temp/file1', 'test/temp/file2', 'test/temp/dir1/file11'], cb
        (cb) ->
          check
            type: 'file'
          , ['test/temp/file1', 'test/temp/file2', 'test/temp/dir1/file11'], cb
      ], cb

    it "only list directories", (cb) ->
      async.series [
        (cb) ->
          check
            type: 'd'
          , ['test/temp/dir1', 'test/temp/dir2'], cb
        (cb) ->
          check
            type: 'dir'
          , ['test/temp/dir1', 'test/temp/dir2'], cb
        (cb) ->
          check
            type: 'directory'
          , ['test/temp/dir1', 'test/temp/dir2'], cb
      ], cb

    it "only list links", (cb) ->
      async.series [
        (cb) ->
          check
            type: 'l'
          , ['test/temp/dir3'], cb
        (cb) ->
          check
            type: 'link'
          , ['test/temp/dir3'], cb
      ], cb

  describe "synchronous", ->

    it "only list files", ->
      checkSync
        type: 'f'
      , ['test/temp/file1', 'test/temp/file2', 'test/temp/dir1/file11']
      checkSync
        type: 'file'
      , ['test/temp/file1', 'test/temp/file2', 'test/temp/dir1/file11']

    it "only list directories", ->
      checkSync
        type: 'd'
      , ['test/temp/dir1', 'test/temp/dir2']
      checkSync
        type: 'dir'
      , ['test/temp/dir1', 'test/temp/dir2']
      checkSync
        type: 'directory'
      , ['test/temp/dir1', 'test/temp/dir2']

    it "only list links", ->
      checkSync
        type: 'l'
      , ['test/temp/dir3']
      checkSync
        type: 'link'
      , ['test/temp/dir3']
