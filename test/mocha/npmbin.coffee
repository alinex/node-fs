chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

describe "npmbin", ->

  fs = require '../../src/index'

  describe "exists", ->
    it "should find npm binary", ->
      result = fs.npmbinSync 'builder'
      expect(result).to.exist

    it "should find npm binary", (cb) ->
      fs.npmbin 'builder', (err, result) ->
        expect(result).to.exist
        cb()
