chai = require 'chai'
expect = chai.expect
{exec} = require 'child_process'

# Only use alinex-error to detect errors, it makes messy output with the normal
# mocha error output.
#require('alinex-error').install()

describe "Find", ->

  fs = require '../../src/index'

  beforeEach (cb) ->
    exec 'mkdir -p test/temp/dir1', ->
      exec 'mkdir -p test/temp/dir2', ->
        exec 'touch test/temp/file1', ->
          exec 'touch test/temp/file2', ->
            exec 'touch test/temp/dir1/file11', ->
              exec 'ln -s dir1 test/temp/dir3', cb

  afterEach (cb) ->
    fs.exists 'test/temp', (exists) ->
      return cb() unless exists
      exec 'rm -r test/temp', cb

  describe "asynchronous", ->

    it "throw error for non-existent dir", (cb) ->
      fs.find 'test/temp/dir999', (err, list) ->
        expect(err, 'error').to.exist
        expect(list, 'result list').to.not.exist
        cb()

    it "lists single file", (cb) ->
      fs.find 'test/temp/file1', (err, list) ->
        expect(err, 'error').to.not.exist
        expect(list, 'result list').to.deep.equal ['test/temp/file1']
        cb()

    it "lists single directory", (cb) ->
      fs.find 'test/temp/dir2', (err, list) ->
        expect(err, 'error').to.not.exist
        expect(list, 'result list').to.deep.equal ['test/temp/dir2']
        cb()

    it "lists softlinked directory as entry", (cb) ->
      fs.find 'test/temp/dir3', (err, list) ->
        expect(err, 'error').to.not.exist
        expect(list, 'result list').to.deep.equal['test/temp/dir3']
        cb()

    it "lists multiple files", (cb) ->
      fs.find 'test/temp', (err, list) ->
        expect(err, 'error').to.not.exist
        expect(list, 'result list').to.deep.equal [
          'test/temp'
          'test/temp/dir1'
          'test/temp/dir1/file11'
          'test/temp/dir2'
          'test/temp/dir3'
          'test/temp/file1'
          'test/temp/file2'
        ]
        cb()

    it "matching files only", (cb) ->
      fs.find 'test/temp',
        include: '*1'
      , (err, list) ->
        expect(err, 'error').to.not.exist
        expect(list, 'result list').to.deep.equal [
          'test/temp/dir1'
          'test/temp/dir1/file11'
          'test/temp/file1'
        ]
        cb()

    it "matching specific levels", (cb) ->
      fs.find 'test/temp',
        mindepth: 1
        maxdepth: 1
      , (err, list) ->
        expect(err, 'error').to.not.exist
        expect(list, 'result list').to.deep.equal [
          'test/temp/dir1'
          'test/temp/dir2'
          'test/temp/dir3'
          'test/temp/file1'
          'test/temp/file2'
        ]
        cb()

    it "lists dereferenced files", (cb) ->
      fs.find 'test/temp',
        dereference: true
      , (err, list) ->
        expect(err, 'error').to.not.exist
        expect(list, 'result list').to.deep.equal [
          'test/temp'
          'test/temp/dir1'
          'test/temp/dir1/file11'
          'test/temp/dir2'
          'test/temp/dir3'
          'test/temp/dir3/file11'
          'test/temp/file1'
          'test/temp/file2'
        ]
        cb()

  describe "synchronous", ->

    it "throw error for non-existent dir", ->
      expect ->
        fs.findSync 'test/temp/dir999'
      .to.throw.error

    it "lists single file", ->
      list = fs.findSync 'test/temp/file1'
      expect(list, 'result list').to.deep.equal ['test/temp/file1']

    it "lists single directory", ->
      list = fs.findSync 'test/temp/dir2'
      expect(list, 'result list').to.deep.equal ['test/temp/dir2']

    it "lists softlinked directory as entry", ->
      list = fs.findSync 'test/temp/dir3'
      expect(list, 'result list').to.deep.equal ['test/temp/dir3']

    it "lists multiple files", ->
      list = fs.findSync 'test/temp'
      expect(list, 'result list').to.deep.equal [
        'test/temp'
        'test/temp/dir1'
        'test/temp/dir1/file11'
        'test/temp/dir2'
        'test/temp/dir3'
        'test/temp/file1'
        'test/temp/file2'
      ]

    it "matching files only", ->
      list = fs.findSync 'test/temp',
        include: '*1'
      expect(list, 'result list').to.deep.equal [
        'test/temp/dir1'
        'test/temp/dir1/file11'
        'test/temp/file1'
      ]

    it "matching specific levels", ->
      list = fs.findSync 'test/temp',
        mindepth: 1
        maxdepth: 1
      expect(list, 'result list').to.deep.equal [
        'test/temp/dir1'
        'test/temp/dir2'
        'test/temp/dir3'
        'test/temp/file1'
        'test/temp/file2'
      ]

    it "lists dereferenced files", ->
      list = fs.findSync 'test/temp',
        dereference: true
      expect(list, 'result list').to.deep.equal [
        'test/temp'
        'test/temp/dir1'
        'test/temp/dir1/file11'
        'test/temp/dir2'
        'test/temp/dir3'
        'test/temp/dir3/file11'
        'test/temp/file1'
        'test/temp/file2'
      ]

