chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###
{exec} = require 'child_process'

describe "Move", ->

  fs = require '../../src/index'

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
      fs.move 'test/temp/dir999', 'test/temp/dir10', (err) ->
        expect(err, 'error').to.exist
        cb()

    it "should move single file", (cb) ->
      fs.move 'test/temp/file1', 'test/temp/file10', (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/file10'), 'new file').to.be.true
        expect(fs.existsSync('test/temp/file1'), 'old file').to.be.false
        cb()

    it "should move single link", (cb) ->
      fs.move 'test/temp/dir3', 'test/temp/dir4', (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir4'), 'new softlink').to.be.true
        expect(fs.existsSync('test/temp/dir3'), 'old softlink').to.be.false
        stats = fs.lstatSync 'test/temp/dir4'
        expect(stats.isSymbolicLink(), 'new softlink').to.be.true
        cb()

    it "should move empty dir", (cb) ->
      fs.move 'test/temp/dir2', 'test/temp/dir4', (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
        expect(fs.existsSync('test/temp/dir2'), 'old dir').to.be.false
        expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.has.length 0
        cb()

    it "should move deep dir", (cb) ->
      fs.move 'test/temp/dir1', 'test/temp/dir4', (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
        expect(fs.existsSync('test/temp/dir1'), 'new dir').to.be.false
        expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.deep.equal ['file11']
        cb()

    it "should fail on move dir into file", (cb) ->
      fs.move 'test/temp/dir1', 'test/temp/file1', (err) ->
        expect(err, 'error').to.exist
        cb()

    it "should fail on move file into dir", (cb) ->
      fs.move 'test/temp/file1', 'test/temp/dir1', (err) ->
        expect(err, 'error').to.exist
        cb()

    it "should fail if file already exists", (cb) ->
      fs.move 'test/temp/file1', 'test/temp/file2', (err) ->
        expect(err, 'error').to.exist
        cb()

    it "should move dir with filter", (cb) ->
      fs.move 'test/temp/dir1', 'test/temp/dir4',
        include: '*le11'
      , (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
        expect(fs.existsSync('test/temp/dir1'), 'old dir').to.be.true
        expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.deep.equal ['file11']
        cb()

    it "should fail on move to existing file", (cb) ->
      fs.move 'test/temp/file1', 'test/temp/file2', (err) ->
        expect(err, 'error').to.exist
        cb()

    it "should overwrite existing file", (cb) ->
      fs.move 'test/temp/file1', 'test/temp/file2',
        overwrite: true
      , (err) ->
        expect(err, 'error').to.not.exist
        cb()

    it "should clen target first", (cb) ->
      fs.move 'test/temp/file1', 'test/temp/file2',
        clean: true
      , (err) ->
        expect(err, 'error').to.not.exist
        cb()


  describe "synchronous", ->

    it "should fail if source don't exist", ->
      expect ->
        fs.moveSync 'test/temp/dir999', 'test/temp/dir10'
      .to.throw Error

    it "should move single file", ->
      fs.moveSync 'test/temp/file1', 'test/temp/file10'
      expect(fs.existsSync('test/temp/file10'), 'new file').to.be.true
      expect(fs.existsSync('test/temp/file1'), 'old file').to.be.false

    it "should move single link", ->
      fs.moveSync 'test/temp/dir3', 'test/temp/dir4'
      expect(fs.existsSync('test/temp/dir4'), 'new softlink').to.be.true
      expect(fs.existsSync('test/temp/dir3'), 'old softlink').to.be.false
      stats = fs.lstatSync 'test/temp/dir4'
      expect(stats.isSymbolicLink(), 'new softlink').to.be.true

    it "should move empty dir", ->
      fs.moveSync 'test/temp/dir2', 'test/temp/dir4'
      expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
      expect(fs.existsSync('test/temp/dir2'), 'old dir').to.be.false
      expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.has.length 0

    it "should move deep dir", ->
      fs.moveSync 'test/temp/dir1', 'test/temp/dir4'
      expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
      expect(fs.existsSync('test/temp/dir1'), 'old dir').to.be.false
      expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.deep.equal ['file11']

    it "should fail on move dir into file", ->
      expect ->
        fs.moveSync 'test/temp/dir1', 'test/temp/file1'
      .to.throw Error

    it "should fail on move file into dir", ->
      expect ->
        fs.moveSync 'test/temp/file1', 'test/temp/dir1'
      .to.throw Error

    it "should fail if file already exists", ->
      expect ->
        fs.moveSync 'test/temp/file1', 'test/temp/file2'
      .to.throw Error

    it "should move dir with filter", ->
      fs.moveSync 'test/temp/dir1', 'test/temp/dir4',
        include: '*le11'
      expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
      expect(fs.existsSync('test/temp/dir1'), 'old dir').to.be.true
      expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.deep.equal ['file11']

    it "should fail on move to existing file", ->
      expect ->
        fs.moveSync 'test/temp/file1', 'test/temp/file2'
      .to.throw Error

    it "should overwrite existing file", ->
      fs.moveSync 'test/temp/file1', 'test/temp/file2',
        overwrite: true

    it "should clean existing file", ->
      fs.moveSync 'test/temp/file1', 'test/temp/file2',
        clean: true
