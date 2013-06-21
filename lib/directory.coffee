fs = require 'fs'
path = require 'path'
directory = {}

directory.rm_recur = (dir, callback) ->
  if fs.lstatSync(dir).isDirectory()
    for subdir in fs.readdirSync(dir)
      directory.rm_recur path.join(dir, subdir)
    fs.rmdirSync dir
  else
    fs.unlinkSync dir
  callback and callback()

directory.mkdir_parent = (dir, mode, callback) ->
  try
    fs.mkdirSync dir, mode
    callback and callback()
  catch error
    if error and error.errno is 34
      directory.mkdir_parent path.dirname(dir), mode, ->
        directory.mkdir_parent dir, mode, callback
    else
      throw error

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

directory.root = (identifier, callback) ->
  cur = process.cwd()
  while cur isnt '/' and not fs.existsSync path.join(cur, identifier)
    cur = path.dirname cur
  callback if fs.existsSync path.join(cur, identifier) then cur else null

module.exports = directory
