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

  it "should do nothing if dir exists", (cb) ->
    fs.mkdirs 'test', (err, made) ->
      expect(err, 'error').to.be.null
      expect(made, 'made dir').to.be.null
      cb()

  it "should return an error if file with dir name exists", (cb) ->
    expect(fs.existsSync('test/mocha/default.coffee'), 'precheck').to.be.true
    fs.mkdirs 'test/mocha/default.coffee', (err, made) ->
      expect(err, 'error').to.be.null
      expect(made, 'made dir').to.be.null
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
###
  it "should fail because directory can't be created", ->
    fs.mkdirs '/test/node/mkdirs', (err, made) ->
      expect(err, 'error').to.be.null
      expect(made, 'made dir').to.be.null
###