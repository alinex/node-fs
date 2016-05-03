chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###
{exec} = require 'child_process'

describe "Touch", ->

  fs = require '../../src/index'
  file = 'test/temp/touch'

  before (cb) ->
    fs.exists 'test/temp', (exists) ->
      return cb() if exists
      exec 'mkdir -p test/temp', cb

  after (cb) ->
    fs.exists 'test/temp', (exists) ->
      return cb() unless exists
      exec 'rm -r test/temp', cb

  describe "asynchronous", ->

    it "should create a new file", (cb) ->
      fs.touch file, (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync(file), 'file path').to.be.true
        cb()

    it "should support noCreate option", (cb) ->
      fs.touch "#{file}-a2", {noCreate: true}, (err) ->
        expect(err, 'error').to.not.exist
        expect(fs.existsSync("#{file}-a2"), 'file path').to.be.false
        cb()

    it "should support time option", (cb) ->
      fs.touch "#{file}", {time: 128178840}, (err) ->
        expect(err, 'error').to.not.exist
        cb()

    it "should support reference option", (cb) ->
      fs.touch "#{file}", {reference: 'test/mocha/touch.coffee'}, (err) ->
        expect(err, 'error').to.not.exist
        cb()

    it "should support noAccess option", (cb) ->
      fs.touch "#{file}", {noAccess: true}, (err) ->
        expect(err, 'error').to.not.exist
        cb()

    it "should support noModified option", (cb) ->
      fs.touch "#{file}", {noModified: true}, (err) ->
        expect(err, 'error').to.not.exist
        cb()

  describe "synchronous", ->

    it "should create a new file", ->
      try
        fs.touchSync file
      catch error
        expect(error, 'error').to.not.exist
      expect(fs.existsSync(file), 'file path').to.be.true

    it "should support noCreate option", ->
      try
        fs.touchSync "#{file}-s2", {noCreate: true}
      catch error
        expect(error, 'error').to.not.exist
      expect(fs.existsSync("#{file}-s2"), 'file path').to.be.false

    it "should support time option", ->
      try
        fs.touchSync "#{file}", {time: 128178840}
      catch error
        expect(error, 'error').to.not.exist

    it "should support reference option", ->
      try
        fs.touchSync "#{file}", {reference: 'test/mocha/touch.coffee'}
      catch error
        expect(error, 'error').to.not.exist

    it "should support noAccess option", ->
      try
        fs.touchSync "#{file}", {noAccess: true}
      catch error
        expect(error, 'error').to.not.exist

    it "should support noModified option", ->
      try
        fs.touchSync "#{file}", {noModified: true}
      catch error
        expect(error, 'error').to.not.exist
