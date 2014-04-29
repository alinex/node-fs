chai = require 'chai'
expect = chai.expect
{exec} = require 'child_process'

describe "Recursive copy", ->

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

    it "should fail if source don't exist", (cb) ->
      fs.copy 'test/temp/dir999', 'test/temp/dir10', (err, list) ->
        expect(err, 'error').to.exist
        cb()

    it.only "should copy single file", (cb) ->
      fs.copy 'test/temp/file1', 'test/temp/file10', (err, list) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync 'test/temp/file10', 'real file').to.exist
        cb()

    it "should copy single link", (cb) ->
    it "should copy empty dir", (cb) ->
    it "should copy deep dir", (cb) ->
    it "should fail on copy dir into file", (cb) ->
    it "should copy file into dir", (cb) ->
    it "should fail if file already exists", (cb) ->
    it "should overwrite file", (cb) ->
