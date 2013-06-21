fs = require 'fs'
path = require 'path'
directory = require '../lib/directory'

describe 'directory', ->
  playground = 'test/playground'
  describe 'rm_recur', ->
    it 'should remove link itself', ->
      fs.mkdirSync 'test/src'
      fs.symlinkSync 'test/src', 'test/des'
      directory.rm_recur 'test/des', ->
        expect(fs.existsSync('test/des')).toEqual(false)
        expect(fs.existsSync('test/src')).toEqual(true)
        fs.rmdirSync 'test/src'

    it 'should remove file', ->
      fs.writeFileSync 'test/tmp', 'content', 'utf8'
      directory.rm_recur 'test/tmp', ->
        expect(fs.existsSync('test/tmp')).toEqual(false)

    it 'should remove directory recursively', ->
      fs.mkdirSync playground
      fs.mkdirSync "#{playground}/a"
      fs.writeFileSync "#{playground}/a/b", 'content of b', 'utf8'
      directory.rm_recur playground, ->
        expect(fs.existsSync(playground)).toEqual(false)

  describe 'mkdir_parent', ->
    beforeEach ->
      fs.mkdirSync playground
    afterEach ->
      directory.rm_recur playground

    it 'should make parent directories as needed', ->
      directory.mkdir_parent "#{playground}/a/b", null, ->
        expect(fs.existsSync "#{playground}/a").toEqual(true)
        expect(fs.existsSync "#{playground}/a/b").toEqual(true)
    
    it 'should throw exception if directory exist', ->
      fs.mkdirSync "#{playground}/a"
      expect(-> directory.mkdir_parent "#{playground}/a").toThrow()

  describe 'traverse', ->
    beforeEach ->
      fs.mkdirSync playground
    afterEach ->
      directory.rm_recur playground

    it 'should also traverse symlink', ->
      directory.mkdir_parent "#{playground}/b/c", null, ->
        fs.symlinkSync "b", "#{playground}/a"
        srcs = []
        directory.traverse "#{playground}/a", (src) ->
          srcs.push src
        expect(srcs.length).toEqual(2)

  describe 'list', ->
    beforeEach ->
      fs.mkdirSync playground
    afterEach ->
      directory.rm_recur playground

    it 'should satisfy filter', ->
      fs.writeFileSync "#{playground}/a.md", 'markdown file', 'utf8'
      fs.writeFileSync "#{playground}/b.html", 'html file', 'utf8'
      directory.list playground, ((src) ->
        path.extname(src) is '.md'
      ), (srcs) -> expect(srcs.length).toEqual(1)

  describe 'root', ->
    beforeEach ->
      fs.mkdirSync playground
    afterEach ->
      directory.rm_recur playground

    it 'should find project root using identifier', ->
      fs.writeFileSync "#{playground}/settings.json", '', 'utf8'
      deep =  "#{playground}/a/b/c/d/e"
      directory.mkdir_parent deep, null, ->
        cur = process.cwd()
        process.chdir deep
        directory.root 'settings.json', (root) ->
          expect(root).toEqual(path.join(cur, playground))
        process.chdir cur
