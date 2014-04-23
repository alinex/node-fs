chai = require 'chai'
expect = chai.expect
{exec} = require 'child_process'

# Only use alinex-error to detect errors, it makes messy output with the normal
# mocha error output.
#require('alinex-error').install()

describe "Recursive mkdirs", ->

  fs = require '../../lib/index.js'

  beforeEach (cb) ->
    fs.exists 'test/temp', (exists) ->
      return cb() unless exists
      exec 'rm -r test/temp', cb

  afterEach (cb) ->
    fs.exists 'test/temp', (exists) ->
      return cb() unless exists
      exec 'rm -r test/temp', cb

  describe "asynchronous", ->

    it "should do nothing if dir exists", (cb) ->
      fs.mkdirs 'test', (err, made) ->
        expect(err, 'error').to.not.exist
        expect(made, 'made dir').to.not.exist
        cb()

    it "should return an error if file with dir name exists", (cb) ->
      expect(fs.existsSync('test/mocha/default.coffee'), 'precheck').to.be.true
      fs.mkdirs 'test/mocha/default.coffee', (err, made) ->
        expect(err, 'error').to.not.exist
        expect(made, 'made dir').to.not.exist
        cb()

    it "should create single missing directory", (cb) ->
      expect(fs.existsSync('test/temp'), 'precheck').to.be.false
      fs.mkdirs 'test/temp', (err, made) ->
        expect(err, 'error').to.be.null
        expect(made, 'made dir').to.have.string "/node-fs/test/temp"
        expect(fs.existsSync('test/temp'), 'postcheck').to.be.true
        cb()

    it "should create multiple directories", (cb) ->
      expect(fs.existsSync('test/temp'), 'precheck').to.be.false
      fs.mkdirs 'test/temp/with/multiple/dirs', (err, made) ->
        expect(err, 'error').to.be.null
        expect(made, 'made dir').to.not.be.null
        expect(fs.existsSync('test/temp'), 'postcheck').to.be.true
        expect(fs.existsSync('test/temp/with'), 'postcheck').to.be.true
        expect(fs.existsSync('test/temp/with/multiple'), 'postcheck').to.be.true
        expect(fs.existsSync('test/temp/with/multiple/dirs'), 'postcheck').to.be.true
        cb()

    it "should fail because directory can't be created", (cb) ->
      fs.mkdirs '/test/node/mkdirs', (err, made) ->
        expect(err, 'error').to.not.be.null
        expect(made, 'made dir').to.not.exist
        cb()

  describe "synchronous", ->

    it "should do nothing if dir exists", ->
      made = fs.mkdirsSync 'test'
      expect(made, 'made dir').to.not.exist

    it "should return an error if file with dir name exists", ->
      expect(fs.existsSync('test/mocha/default.coffee'), 'precheck').to.be.true
      made = fs.mkdirsSync 'test/mocha/default.coffee'
      expect(made, 'made dir').to.not.exist

    it "should create single missing directory", ->
      expect(fs.existsSync('test/temp'), 'precheck').to.be.false
      made = fs.mkdirsSync 'test/temp'
      expect(made, 'made dir').to.have.string "/node-fs/test/temp"
      expect(fs.existsSync('test/temp'), 'postcheck').to.be.true

    it "should create multiple directories", ->
      expect(fs.existsSync('test/temp'), 'precheck').to.be.false
      made = fs.mkdirsSync 'test/temp/with/multiple/dirs'
      expect(made, 'made dir').to.not.be.null
      expect(fs.existsSync('test/temp'), 'postcheck').to.be.true
      expect(fs.existsSync('test/temp/with'), 'postcheck').to.be.true
      expect(fs.existsSync('test/temp/with/multiple'), 'postcheck').to.be.true
      expect(fs.existsSync('test/temp/with/multiple/dirs'), 'postcheck').to.be.true

    it "should fail because directory can't be created", ->
      expect ->
        fs.mkdirsSync '/test/node/mkdirs'
      .to.throw Error
