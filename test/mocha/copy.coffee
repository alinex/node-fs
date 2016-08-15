chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###
{exec} = require 'child_process'

describe "Recursive copy", ->

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

  describe.only "asynchronous", ->

    it "should fail if source don't exist", (cb) ->
      fs.copy 'test/temp/dir999', 'test/temp/dir10', (err) ->
        expect(err, 'error').to.exist
        cb()

    it "should copy single file", (cb) ->
      fs.copy 'test/temp/file1', 'test/temp/file10', (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/file10'), 'real file').to.be.true
        cb()

    it "should copy single link", (cb) ->
      fs.copy 'test/temp/dir3', 'test/temp/dir4', (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir4'), 'new softlink').to.be.true
        stats = fs.lstatSync 'test/temp/dir4'
        expect(stats.isSymbolicLink(), 'new softlink').to.be.true
        cb()

    it "should copy empty dir", (cb) ->
      fs.copy 'test/temp/dir2', 'test/temp/dir4', (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
        expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.has.length 0
        cb()

    it "should copy deep dir", (cb) ->
      fs.copy 'test/temp/dir1', 'test/temp/dir4', (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
        expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.deep.equal ['file11']
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

    it "should copy dir with filter", (cb) ->
      fs.copy 'test/temp/dir1', 'test/temp/dir4',
        include: '*1'
      , (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
        expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.deep.equal ['file11']
        cb()

    it "should copy deep dir", (cb) ->
      fs.copy 'test/temp/dir1', 'test/temp/dir4',
        mindepth: 1
        maxdepth: 1
      , (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
        expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.deep.equal ['file11']
        fs.copy 'test/temp/dir1', 'test/temp/dir5',
          mindepth: 0
          maxdepth: 0
        , (err) ->
          expect(err, 'error').to.not.exist
          expect(fs.existsSync('test/temp/dir5'), 'new dir').to.be.true
          expect(fs.readdirSync('test/temp/dir5'), 'new dir').to.deep.equal []
          cb()

    it "should copy with dereferencing", (cb) ->
      fs.copy 'test/temp/dir3', 'test/temp/dir4',
        dereference: true
      , (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
        expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.deep.equal ['file11']
        cb()

    it "should fail on copy to existing file", (cb) ->
      fs.copy 'test/temp/file1', 'test/temp/file2', (err) ->
        expect(err, 'error').to.exist
        cb()

    it "should overwrite existing file", (cb) ->
      fs.copy 'test/temp/file1', 'test/temp/file2',
        overwrite: true
      , (err) ->
        expect(err, 'error').to.not.exist
        cb()

    it "should ignore existing file", (cb) ->
      fs.copy 'test/temp/file1', 'test/temp/file2',
        ignore: true
      , (err) ->
        expect(err, 'error').to.not.exist
        cb()


  describe "synchronous", ->

    it "should fail if source don't exist", ->
      expect ->
        fs.copySync 'test/temp/dir999', 'test/temp/dir10'
      .to.throw Error

    it "should copy single file", ->
      fs.copySync 'test/temp/file1', 'test/temp/file10'
      expect(fs.existsSync('test/temp/file10'), 'real file').to.be.true

    it "should copy single link", ->
      fs.copySync 'test/temp/dir3', 'test/temp/dir4'
      expect(fs.existsSync('test/temp/dir4'), 'new softlink').to.be.true
      stats = fs.lstatSync 'test/temp/dir4'
      expect(stats.isSymbolicLink(), 'new softlink').to.be.true

    it "should copy empty dir", ->
      fs.copySync 'test/temp/dir2', 'test/temp/dir4'
      expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
      expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.has.length 0

    it "should copy deep dir", ->
      fs.copySync 'test/temp/dir1', 'test/temp/dir4'
      expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
      expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.deep.equal ['file11']

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

    it "should copy dir with filter", ->
      fs.copySync 'test/temp/dir1', 'test/temp/dir4',
        include: '*1'
      expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
      expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.deep.equal ['file11']

    it "should copy deep dir", ->
      fs.copySync 'test/temp/dir1', 'test/temp/dir4',
        mindepth: 1
        maxdepth: 1
      expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
      expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.deep.equal ['file11']
      fs.copySync 'test/temp/dir1', 'test/temp/dir5',
        mindepth: 0
        maxdepth: 0
      expect(fs.existsSync('test/temp/dir5'), 'new dir').to.be.true
      expect(fs.readdirSync('test/temp/dir5'), 'new dir').to.deep.equal []

    it "should copy with dereferencing", ->
      fs.copySync 'test/temp/dir3', 'test/temp/dir4',
        dereference: true
      expect(fs.existsSync('test/temp/dir4'), 'new dir').to.be.true
      expect(fs.readdirSync('test/temp/dir4'), 'new dir').to.deep.equal ['file11']

    it "should fail on copy to existing file", ->
      expect ->
        fs.copySync 'test/temp/file1', 'test/temp/file2'
      .to.throw Error

    it "should overwrite existing file", ->
      fs.copySync 'test/temp/file1', 'test/temp/file2',
        overwrite: true

    it "should ignore existing file", ->
      fs.copySync 'test/temp/file1', 'test/temp/file2',
        ignore: true
