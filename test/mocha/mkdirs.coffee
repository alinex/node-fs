chai = require 'chai'
expect = chai.expect
require('alinex-error').install()

describe "Recursive mkdirs", ->

  fs = require '../../lib/index.js'

  it "should do nothing if dir exists", ->
    fs.mkdirs 'test', (err, made) ->
      expect(err, 'error').to.be.null
      expect(made, 'made dir').to.be.null

  it "should return an error if file with dir name exists", ->

  it "should create single missing directory", ->

  it "should create multiple directories", ->

  it "should fail because directory can'T be created", ->

    fs.exists '.', (exists) ->
      expect(exists).to.be.true
