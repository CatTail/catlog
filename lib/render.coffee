fs = require 'fs'
path = require 'path'
_ = require 'underscore'
async = require 'async'
mustache = require 'mustache'
directory = require './directory'
parser = require './parser'
RSS = require 'rss'
render = {}

render.render = (env, callback) ->
  @env = env
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
    callback and callback()

render.render_post = (post, env, callback) ->
  context = _.defaults _.clone(env), {post: post}
  html = mustache.render @read_template('post'), context, @partials()
  dest = path.join(env.destination, post.permalink)
  if not fs.existsSync path.dirname dest
    directory.mkdir_parent path.dirname dest
  fs.writeFileSync dest, html, 'utf8'
  callback and callback()

render.render_index = (env, callback) ->
  context = _.defaults _.clone(env), {posts: env.posts}
  html = mustache.render @read_template('index'), context, @partials()
  fs.writeFileSync path.join(env.destination, 'index.html'), html, 'utf8'
  callback and callback()

render.render_list = (posts, env, dest, callback) ->
  context = _.defaults _.clone(env), {posts: env.posts}
  html = mustache.render @read_template('list'), context, @partials()
  fs.writeFileSync path.join(env.destination, dest, 'index.html'), html, 'utf8'
  callback and callback()

render.render_feed = (env, callback) ->
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
  callback and callback()

render.read_template = (filename) ->
  fs.readFileSync "themes/#{@env.theme}/#{filename}.html", 'utf8'

render.partials = ->
  {header: @read_template('header'), footer: @read_template('footer')}

module.exports = render
