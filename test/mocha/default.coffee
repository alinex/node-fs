chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

describe "Nodes default methods:", ->

  fs = require '../../src/index'

  describe "exists", ->
    it "should return true for existing file", ->
      fs.exists '.', (exists) ->
        expect(exists, 'exists').to.be.true
    it "should return false for non existing file", ->
      fs.exists './this-will-not-exist', (exists) ->
        expect(exists, 'exists').to.be.false
