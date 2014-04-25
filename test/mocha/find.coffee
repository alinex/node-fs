chai = require 'chai'
expect = chai.expect
{exec} = require 'child_process'

# Only use alinex-error to detect errors, it makes messy output with the normal
# mocha error output.
#require('alinex-error').install()

describe "Find", ->

  fs = require '../../lib/index.js'

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

  describe "asynchronous", ->

    it "lists single file", (cb) ->
      fs.find 'test/temp/file1', (err, list) ->
        expect(err, 'error').to.not.exist
        expect(list, 'result list').to.has.length 1
        expect(list[0], 'result list').to.equal 'test/temp/file1'
        cb()

    it "lists single directory", (cb) ->
      fs.find 'test/temp/dir2', (err, list) ->
        expect(err, 'error').to.not.exist
        expect(list, 'result list').to.has.length 1
        expect(list[0], 'result list').to.equal 'test/temp/dir2'
        cb()

    it "lists softlinked directory as entry", (cb) ->
      fs.find 'test/temp/dir3', (err, list) ->
        expect(err, 'error').to.not.exist
        expect(list, 'result list').to.has.length 1
        expect(list[0], 'result list').to.equal 'test/temp/dir3'
        cb()

    it "lists multiple files", (cb) ->
      fs.find 'test/temp', (err, list) ->
        expect(err, 'error').to.not.exist
        expect(list, 'result list').to.has.length 7
        cb()

