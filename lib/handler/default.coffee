fs = require 'fs-extra'
path = require 'path'
_ = require 'underscore'
marked = require 'marked'
directory = require '../directory'
engine = {
  ejs: require 'ejs'
  jade: require 'jade'
}
handler = {}

marked.setOptions {
  gfm: true
  tables: true
  breaks: false
  pedantic: false
  sanitize: false
  smartLists: true
  langPrefix: ''
}

handler.parse = (post, callback) ->
  content = fs.readFileSync post.src, 'utf8'
  content = marked.parser marked.lexer content
  post.content = content
  callback()

handler.render = (post, callback) ->
  # markdown interpolation
  if post.content
    post.content = engine.ejs.render post.content, post
  # render
  src = path.join post.theme_path, post.theme, 'post'
  dest = path.join post.destination, post.permalink
  # use index.html if permalink don't have filename
  dest = path.join(dest, if path.extname dest then '' else 'index.html')
  # post
  dir = path.dirname src
  type = path.basename src
  for file in fs.readdirSync dir
    if file.indexOf(type) is 0
      format = path.extname(file).slice(1)
      filename = "#{src}.#{format}"
      raw = fs.readFileSync filename, 'utf8'
      html = engine[format].render raw, _.defaults({filename: filename}, post)
  if not fs.existsSync path.dirname dest
    directory.mkdir_parent path.dirname(dest), null
  fs.writeFileSync dest, html, 'utf8'
  # assets
  # use current directory if permalink don't have filename
  assets = path.join path.dirname(post.src), 'assets'
  fs.copy "#{assets}", "#{path.dirname dest}/assets"

module.exports = handler
