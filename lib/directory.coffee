fs = require 'fs'
path = require 'path'
directory = {}

directory.mkdir_parent = (dir, mode, callback) ->
  try
    fs.mkdirSync dir, mode
    callback and callback()
  catch error
    if error and error.errno is 34
      directory.mkdir_parent path.dirname(dir), mode, ->
        directory.mkdir_parent dir, mode, callback

directory.traverse = (dir, callback) ->
  callback dir
  if fs.statSync(dir).isDirectory()
    for subdir in fs.readdirSync(dir)
      directory.traverse path.join(dir, subdir), callback

directory.list = (dir, filter, callback) ->
  srcs = []
  @traverse dir, (src) ->
    if not filter or filter src
      srcs.push src
  callback srcs

directory.root = (callback) ->
  cur = process.cwd()
  while cur isnt '/' and not fs.existsSync path.join(cur, 'settings.json')
    cur = path.dirname cur
  callback if fs.existsSync path.join(cur, 'settings.json') then cur else null

module.exports = directory
