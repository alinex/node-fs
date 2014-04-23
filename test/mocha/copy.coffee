chai = require 'chai'
expect = chai.expect
{exec} = require 'child_process'

describe "Recursive copy", ->

  fs = require '../../lib/index.js'

  describe "asynchronous", ->

    it "should fail if source don't exist", (cb) ->
    it "should copy single file", (cb) ->
    it "should copy single link", (cb) ->
    it "should copy empty dir", (cb) ->
    it "should copy deep dir", (cb) ->
    it "should fail on copy dir into file", (cb) ->
    it "should copy file into dir", (cb) ->
    it "should fail if file already exists", (cb) ->
    it "should overwrite file", (cb) ->
