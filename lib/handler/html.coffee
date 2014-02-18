fs = require 'fs-extra'
path = require 'path'
directory = require '../directory'
handler = {}

handler.parse = (post, callback) ->
  callback()

handler.render = (post, callback) ->
  dest = path.join post.destination, post.permalink
  dest = if path.extname dest then path.dirname dest else dest
  # untouch post, just copy
  console.log path.dirname(post.src), dest
  if not fs.existsSync path.dirname dest
    directory.mkdir_parent path.dirname(dest), null
  fs.copy path.dirname(post.src), dest

module.exports = handler
