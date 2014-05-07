chai = require 'chai'
expect = chai.expect
async = require 'async'
util = require 'util'
{exec} = require 'child_process'
fs = require 'fs'

# Only use alinex-error to detect errors, it makes messy output with the normal
# mocha error output.
#require('alinex-error').install()

describe "Filter on file size", ->

  filter = require '../../lib/filter'

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
        fs.writeFile 'test/temp/file1', '0123456789', ->
          fs.writeFile 'test/temp/file2', '01234567890123456789', ->
            fs.writeFile 'test/temp/dir1/file11', '0123456789', ->
              exec 'ln -s dir1 test/temp/dir3', cb

  afterEach (cb) ->
    fs.exists 'test/temp', (exists) ->
      return cb() unless exists
      exec 'rm -r test/temp', cb


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

    it "find all files", (cb) ->
      async.series [
        (cb) ->
          check
            minsize: 0
          , files, cb
        (cb) ->
          check
            maxsize: 1024 * 1024
          , files, cb
        (cb) ->
          check
            maxsize: '1M'
          , files, cb
      ], cb

    it "find large files", (cb) ->
      async.series [
        (cb) ->
          check
            minsize: 15
          , ['test/temp/file2', 'test/temp/dir1', 'test/temp/dir2'], cb
      ], cb

    it "find small files", (cb) ->
      async.series [
        (cb) ->
          check
            maxsize: 15
          , ['test/temp/file1', 'test/temp/dir1/file11', 'test/temp/dir3'], cb
      ], cb

    it "find files in range", (cb) ->
      async.series [
        (cb) ->
          check
            minsize: 15
            maxsize: 25
          , ['test/temp/file2'], cb
        (cb) ->
          check
            minsize: 20
            maxsize: 20
          , ['test/temp/file2'], cb
      ], cb

  describe "synchronous", ->

    it "find all files", ->
      checkSync
        minsize: 0
      , files
      checkSync
        maxsize: 1024 * 1024
      , files

    it "find large files", ->
      checkSync
        minsize: 15
      , ['test/temp/file2', 'test/temp/dir1', 'test/temp/dir2']

    it "find small files", ->
      checkSync
        maxsize: 15
      , ['test/temp/file1', 'test/temp/dir1/file11', 'test/temp/dir3']

    it "find files in range", ->
      checkSync
        minsize: 15
        maxsize: 25
      , ['test/temp/file2']
      checkSync
        minsize: 20
        maxsize: 20
      , ['test/temp/file2']
