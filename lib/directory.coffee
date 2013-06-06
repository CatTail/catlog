fs = require 'fs'
path = require 'path'
directory = {}

directory.mkdir_parent = (dir, mode) ->
  try
    fs.mkdirSync dir, mode
  catch error
    if error and error.errno is 34
      directory.mkdir_parent path.dirname(dir), mode
      directory.mkdir_parent dir, mode

directory.traverse = (dir, handler) ->
  handler dir
  if fs.statSync(dir).isDirectory()
    for subdir in fs.readdirSync(dir)
      directory.traverse path.join(dir, subdir), handler

directory.list = (dir, filter) ->
  srcs = []
  @traverse dir, (src) ->
    if not filter or filter src
      srcs.push src
  return srcs

module.exports = directory
