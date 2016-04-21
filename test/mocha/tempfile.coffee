chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

describe "Tempfile", ->

  fs = require '../../src/index'

  describe "asynchronous", ->

    it "should create a new file", (cb) ->
      fs.tempfile (err, file) ->
        expect(err, 'error').to.not.exist
        expect(file, 'file path').to.exist
        # cleanup
        fs.remove file, cb

    it "should fail if source don't exist", (cb) ->
      fs.tempfile '/unexisting/file', (err) ->
        expect(err, 'error').to.exist
        cb()



  describe "synchronous", ->

    it "should create a new file", ->
      try
        file = fs.tempfileSync()
      catch error
        expect(error, 'error').to.not.exist
      expect(file, 'file path').to.exist
      # cleanup
      fs.removeSync file

    it "should fail if source don't exist", ->
      try
        fs.tempfileSync '/unexisting/file'
      catch error
      expect(error, 'error').to.exist
