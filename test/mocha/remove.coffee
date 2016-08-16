chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###
{exec} = require 'child_process'

describe.skip "Remove", ->

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

    it "should do nothing if file does not exist", (cb) ->
      fs.remove 'test/temp/file-do-not-exist', (err, removed) ->
        expect(err, 'error').to.not.exist
        expect(removed, 'removed path').to.not.exist
        cb()

    it "should remove a simple file", (cb) ->
      expect(fs.existsSync('test/temp/file1'), 'precheck').to.be.true
      fs.remove 'test/temp/file1', (err, removed) ->
        expect(err, 'error').to.not.exist
        expect(removed, 'removed path').to.have.string 'test/temp/file1'
        expect(fs.existsSync('test/temp/file1', 'oldfile'), 'postcheck').to.be.false
        cb()

    it "should remove an empty directory", (cb) ->
      expect(fs.existsSync('test/temp/dir2'), 'precheck').to.be.true
      fs.remove 'test/temp/dir2', (err, removed) ->
        expect(err, 'error').to.be.null
        expect(removed, 'removed path').to.have.string "test/temp/dir2"
        expect(fs.existsSync('test/temp/dir2'), 'postcheck').to.be.false
        cb()

    it "should remove an non empty directory", (cb) ->
      expect(fs.existsSync('test/temp/dir1'), 'precheck').to.be.true
      fs.remove 'test/temp/dir1', (err, removed) ->
        expect(err, 'error').to.be.null
        expect(removed, 'removed path').to.have.string "test/temp/dir1"
        expect(fs.existsSync('test/temp/dir1'), 'postcheck').to.be.false
        cb()

    it "should fail to remove system file", (cb) ->
      file = '/proc/cpuinfo' if fs.existsSync '/proc/cpuinfo'
      file = '/.file' if fs.existsSync '/.file'
      return cb() unless file
      fs.remove file, (err, removed) ->
        expect(err, 'error').to.not.be.null
        expect(err.code, 'error').to.exist
        expect(removed, 'removed path').to.not.exist
        cb()

    it "should remove only pattern matches", (cb) ->
      expect(fs.existsSync('test/temp/dir1'), 'precheck').to.be.true
      fs.remove 'test/temp/dir1',
        include: '*11'
      , (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir1'), 'unmatched dir').to.be.true
        expect(fs.existsSync('test/temp/dir1/file11'), 'removed file').to.be.false
        cb()

    it "should remove only specific level", (cb) ->
      expect(fs.existsSync('test/temp/dir1'), 'precheck').to.be.true
      fs.remove 'test/temp/dir1',
        mindepth: '1'
      , (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir1'), 'dir').to.be.true
        expect(fs.existsSync('test/temp/dir1/file11'), 'removed file').to.be.false
        cb()

    it "should remove with dereferencing", (cb) ->
      expect(fs.existsSync('test/temp/dir3'), 'precheck').to.be.true
      fs.remove 'test/temp/dir3',
        dereference: true
      , (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync('test/temp/dir3'), 'link').to.be.false
        expect(fs.existsSync('test/temp/dir1/file11'), 'removed file').to.be.false
        cb()

  describe "synchronous", ->

    it "should do nothing if file not exist", ->
      removed = fs.removeSync 'test/temp/file-do-not-exist'
      expect(removed, 'removed path').to.not.exist

    it "should remove a simple file", ->
      expect(fs.existsSync('test/temp/file1'), 'precheck').to.be.true
      removed = fs.removeSync 'test/temp/file1'
      expect(removed, 'removed path').to.have.string 'test/temp/file1'
      expect(fs.existsSync('test/temp/file1'), 'postcheck').to.be.false

    it "should remove an empty directory", ->
      expect(fs.existsSync('test/temp/dir2'), 'precheck').to.be.true
      removed = fs.removeSync 'test/temp/dir2'
      expect(removed, 'removed path').to.have.string "/node-fs/test/temp/dir2"
      expect(fs.existsSync('test/temp/dir2'), 'postcheck').to.be.false

    it "should remove an non empty directory", ->
      expect(fs.existsSync('test/temp/dir1'), 'precheck').to.be.true
      removed = fs.removeSync 'test/temp/dir1'
      expect(removed, 'removed path').to.have.string "/node-fs/test/temp/dir1"
      expect(fs.existsSync('test/temp/dir1'), 'postcheck').to.be.false

    it "should fail to remove system file", ->
      file = '/proc/cpuinfo' if fs.existsSync '/proc/cpuinfo'
      file = '/.file' if fs.existsSync '/.file'
      return unless file
      expect ->
        fs.removeSync file
      .to.throw Error

    it "should remove only pattern matches", ->
      expect(fs.existsSync('test/temp/dir1'), 'precheck').to.be.true
      fs.removeSync 'test/temp/dir1',
        include: '*11'
      expect(fs.existsSync('test/temp/dir1'), 'unmatched dir').to.be.true
      expect(fs.existsSync('test/temp/dir1/file11'), 'removed file').to.be.false

    it "should remove only specific level", ->
      expect(fs.existsSync('test/temp/dir1'), 'precheck').to.be.true
      fs.removeSync 'test/temp/dir1',
        mindepth: '1'
      expect(fs.existsSync('test/temp/dir1'), 'dir').to.be.true
      expect(fs.existsSync('test/temp/dir1/file11'), 'removed file').to.be.false

    it "should remove with dereferencing", ->
      expect(fs.existsSync('test/temp/dir3'), 'precheck').to.be.true
      fs.removeSync 'test/temp/dir3',
        dereference: true
      expect(fs.existsSync('test/temp/dir3'), 'link').to.be.false
      expect(fs.existsSync('test/temp/dir1/file11'), 'removed file').to.be.false
