chai = require 'chai'
expect = chai.expect
async = require 'async'
util = require 'util'
{exec} = require 'child_process'
fs = require 'fs'

# Only use alinex-error to detect errors, it makes messy output with the normal
# mocha error output.
#require('alinex-error').install()

describe "Filter by owner", ->

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

    it "should find by uid", (cb) ->
      async.series [
        (cb) ->
          check
            user: process.uid
          , files, cb
      ], cb

    it "should find by username", (cb) ->
      async.series [
        (cb) ->
          check
            user: process.env.USER
          , files, cb
      ], cb

    it "should find by gid", (cb) ->
      async.series [
        (cb) ->
          check
            group: process.gid
          , files, cb
      ], cb

  describe "synchronous", ->

    it "should find by uid", ->
      checkSync
        user: process.uid
      , files

    it "should find by username", ->
      checkSync
        user: process.env.USER
      , files

    it "should find by gid", ->
      checkSync
        group: process.gid
      , files
