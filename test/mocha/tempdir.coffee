chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

describe "Tempdir", ->

  fs = require '../../lib/index'

  describe "asynchronous", ->

    it "should create a new directory", (cb) ->
      fs.tempdir (err, dir) ->
        expect(err, 'error').to.not.exist
        expect(dir, 'directory path').to.exist
        # cleanup
        fs.remove dir, cb

    it "should fail if source don't exist", (cb) ->
      fs.tempdir '/unexisting/directory', (err) ->
        expect(err, 'error').to.exist
        cb()



  describe "synchronous", ->

    it "should create a new directory", ->
      try
        dir = fs.tempdirSync()
      catch error
        expect(error, 'error').to.not.exist
      expect(dir, 'directory path').to.exist
      # cleanup
      fs.removeSync dir

    it "should fail if source don't exist", ->
      try
        fs.tempdirSync '/unexisting/directory'
      catch error
      expect(error, 'error').to.exist
