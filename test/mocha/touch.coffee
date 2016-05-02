chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###
{exec} = require 'child_process'

describe "Touch", ->

  fs = require '../../src/index'
  file = 'test/temp/touch'

  beforeEach (cb) ->
    fs.exists 'test/temp', (exists) ->
      return cb() if exists
      exec 'mkdir -p test/temp', cb

  afterEach (cb) ->
    fs.exists 'test/temp', (exists) ->
      return cb() unless exists
      exec 'rm -r test/temp', cb

  describe "asynchronous", ->

    it "should create a new file", (cb) ->
      fs.touch file, (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync(file), 'file path').to.be.true
        cb()

    it "should fail if no-cretae option", (cb) ->
      fs.touch "#{file}2", {noCreate: true}, (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync("#{file}2"), 'file path').to.be.false
        cb()


  describe "synchronous", ->

    it "should create a new file", ->
      try
        fs.touchSync file
      catch error
        expect(error, 'error').to.not.exist
      expect(fs.existsSync(file), 'file path').to.be.true

    it "should fail if source don't exist", ->
      try
        fs.touchSync file, {noCreate: true}
      catch error
        expect(error, 'error').to.not.exist
      expect(fs.existsSync(file), 'file path').to.be.false
