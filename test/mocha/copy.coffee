chai = require 'chai'
expect = chai.expect
{exec} = require 'child_process'

describe "Recursive copy", ->

  fs = require '../../src/index.js'

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
      fs.copy 'test/temp/dir999', 'test/temp/dir10', (err) ->
        expect(err, 'error').to.exist
        cb()

    it "should copy single file", (cb) ->
      fs.copy 'test/temp/file1', 'test/temp/file10', (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync 'test/temp/file10', 'real file').to.exist
        cb()

    it "should copy single link", (cb) ->
      fs.copy 'test/temp/dir3', 'test/temp/dir4', (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync 'test/temp/dir4', 'softlink').to.exist
        stats = fs.lstatSync 'test/temp/dir4'
        expect(stats.isSymbolicLink(), 'softlink').to.be.true
        cb()

    it "should copy empty dir", (cb) ->
      fs.copy 'test/temp/dir2', 'test/temp/dir4', (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync 'test/temp/dir4', 'dir').to.exist
        expect(fs.readdirSync 'test/temp/dir4').to.has.length 0
        cb()

    it "should copy deep dir", (cb) ->
      fs.copy 'test/temp/dir1', 'test/temp/dir4', (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync 'test/temp/dir4', 'dir').to.exist
        expect(fs.readdirSync 'test/temp/dir4').to.has.length 1
        cb()

    it "should fail on copy dir into file", (cb) ->
      fs.copy 'test/temp/dir1', 'test/temp/file1', (err) ->
        expect(err, 'error').to.exist
        cb()

    it "should fail on copy file into dir", (cb) ->
      fs.copy 'test/temp/file1', 'test/temp/dir1', (err) ->
        expect(err, 'error').to.exist
        cb()

    it "should fail if file already exists", (cb) ->
      fs.copy 'test/temp/file1', 'test/temp/file2', (err) ->
        expect(err, 'error').to.exist
        cb()

  describe "synchronous", ->

    it "should fail if source don't exist", ->
      expect ->
        fs.copySync 'test/temp/dir999', 'test/temp/dir10'
      .to.throw Error

    it "should copy single file", ->
      fs.copySync 'test/temp/file1', 'test/temp/file10'
      expect(fs.existsSync 'test/temp/file10', 'real file').to.exist

    it "should copy single link", ->
      fs.copySync 'test/temp/dir3', 'test/temp/dir4'
      expect(fs.existsSync 'test/temp/dir4', 'softlink').to.exist
      stats = fs.lstatSync 'test/temp/dir4'
      expect(stats.isSymbolicLink(), 'softlink').to.be.true

    it "should copy empty dir", ->
      fs.copySync 'test/temp/dir2', 'test/temp/dir4'
      expect(fs.existsSync 'test/temp/dir4', 'dir').to.exist
      expect(fs.readdirSync 'test/temp/dir4').to.has.length 0

    it "should copy deep dir", ->
      fs.copySync 'test/temp/dir1', 'test/temp/dir4'
      expect(fs.existsSync 'test/temp/dir4', 'dir').to.exist
      expect(fs.readdirSync 'test/temp/dir4').to.has.length 1

    it "should fail on copy dir into file", ->
      expect ->
        fs.copySync 'test/temp/dir1', 'test/temp/file1'
      .to.throw Error

    it "should fail on copy file into dir", ->
      expect ->
        fs.copySync 'test/temp/file1', 'test/temp/dir1'
      .to.throw Error

    it "should fail if file already exists", ->
      expect ->
        fs.copySync 'test/temp/file1', 'test/temp/file2'
      .to.throw Error

