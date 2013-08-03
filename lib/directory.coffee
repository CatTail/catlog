fs = require 'fs'
path = require 'path'
directory = {}

directory.rm_recur = (dir) ->
  if fs.lstatSync(dir).isDirectory()
    for subdir in fs.readdirSync(dir)
      directory.rm_recur path.join(dir, subdir)
    fs.rmdirSync dir
  else
    fs.unlinkSync dir

directory.mkdir_parent = (dir, mode) ->
  try
    fs.mkdirSync dir, mode
  catch error
    if error and error.errno is 34
      directory.mkdir_parent path.dirname(dir), mode
      directory.mkdir_parent dir, mode
    else
      throw error

directory.traverse = (dir, iterator) ->
  iterator dir
  if fs.statSync(dir).isDirectory()
    for subdir in fs.readdirSync(dir)
      directory.traverse path.join(dir, subdir), iterator

directory.list = (dir, filter) ->
  srcs = []
  directory.traverse dir, (src) ->
    if not filter or filter src
      srcs.push src
  return srcs

directory.root = (identifier) ->
  cur = process.cwd()
  while cur isnt '/' and not fs.existsSync path.join(cur, identifier)
    cur = path.dirname cur
  return if fs.existsSync path.join(cur, identifier) then cur else null

module.exports = directory
