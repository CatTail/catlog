fs = require 'fs'
path = require 'path'
_ = require 'underscore'
marked = require 'marked'
async = require 'async'
pygments = require 'pygments'
ejs = require 'ejs'
directory = require './directory'
parser = require './parser'
RSS = require 'rss'
render = {}

render.render = (env, callback) ->
  marked.setOptions {
    gfm: true
    tables: true
    breaks: false
    pedantic: false
    sanitize: true
    smartLists: true
    langPrefix: 'highlight lang-'
  }
  # hack for pygment syntax async highlight
  async.forEach env.posts, ((post, callback) =>
    @render_post post, env, callback
    env.auto and fs.watchFile post.src, {persistent: true, interval: 1000}, =>
      console.log 'update'
      @render_post post, env
  ), =>
    @render_index env
    for category in env.categories
      posts = (post for post in env.posts when post.category is category)
      @render_list posts, env, category
    @render_feed env
    callback && callback()

render.render_post = (post, env, callback) ->
  tokens = marked.lexer post.content
  async.forEach tokens, ((token, callback) ->
    if token.type is 'code'
      pygments.colorize token.text, token.lang, 'html', ((data) ->
        token.escaped = true
        token.text = data
        callback()
      ), {'P': 'nowrap=true'}
    else
      callback()
  ), ->
    post.content = marked.parser tokens
    filename = "themes/#{env.theme}/post.ejs"
    html = ejs.render fs.readFileSync(filename, 'utf8'),
      _.defaults {content: post.content, filename: filename}, env
    if not fs.existsSync path.dirname post.dest
      directory.mkdir_parent path.dirname post.dest
    fs.writeFileSync post.dest, html, 'utf8'
    callback && callback()

render.render_index = (env) ->
  filename = path.join "themes/#{env.theme}/index.ejs"
  html = ejs.render fs.readFileSync(filename, 'utf8'),
      _.defaults {posts: env.posts, filename: filename}, env
  fs.writeFileSync path.join(env.destination, 'index.html'), html, 'utf8'

render.render_list = (posts, env, dest) ->
  filename = path.join "themes/#{env.theme}/list.ejs"
  html = ejs.render fs.readFileSync(filename, 'utf8'),
      _.defaults {posts: posts, filename: filename}, env
  fs.writeFileSync path.join(env.destination, dest, 'index.html'), html, 'utf8'

render.render_feed = (env) ->
  console.log env
  feed = new RSS {
    title: env.site_title
    description: env.description
    feed_url: "#{env.site_url}/feed.xml"
    site_url: "#{env.site_url}"
    author: env.author
  }
  for post in env.posts
    feed.item {
      title: post.name
      description: post.content
      url: "#{env.site_url}#{env.base_url}#{post.permalink}"
      author: post.author
      date: post.date
    }
  fs.writeFileSync path.join(env.destination, 'feed.xml'), feed.xml(), 'utf8'

module.exports = render
