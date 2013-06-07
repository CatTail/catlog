fs = require 'fs'
path = require 'path'
_ = require 'underscore'
async = require 'async'
jade = require 'jade'
directory = require './directory'
parser = require './parser'
rss = require 'rss'
render = {}

render.render = (site, callback) ->
  fn_post = @compile_template 'post', site.theme_path
  fn_index = @compile_template 'index', site.theme_path
  fn_list = @compile_template 'list', site.theme_path
  async.forEach site.posts, ((post, callback) =>
    dest = path.join(site.destination, post.permalink)
    @render_file fn_post, {post: post, site: site}, dest, callback
    site.auto and fs.watchFile post.src, {persistent: true, interval: 1000}, =>
      console.log 'update'
      @render_file fn_post, {site: site, post: post}, dest, callback
  ), =>
    dest = path.join site.destination, 'index.html'
    @render_file fn_index, {site: site, posts: site.posts}, dest
    for category in site.categories
      posts = (post for post in site.posts when post.category is category)
      dest = path.join site.destination, category, 'index.html'
      @render_file fn_list, {site: site, posts: posts}, dest
    @render_feed site
    callback and callback()

render.render_file = (fn, context, dest, callback) ->
  html = fn context
  if not fs.existsSync path.dirname dest
    directory.mkdir_parent path.dirname dest
  fs.writeFileSync dest, html, 'utf8'
  callback and callback()

render.render_feed = (site, callback) ->
  feed = new rss {
    title: site.site_title
    description: site.description
    feed_url: "#{site.site_url}/feed.xml"
    site_url: "#{site.site_url}"
    author: site.author
  }
  for post in site.posts
    feed.item {
      title: post.name
      description: post.content
      url: "#{site.site_url}#{site.base_url}#{post.permalink}"
      author: post.author
      date: post.date
    }
  fs.writeFileSync path.join(site.destination, 'feed.xml'), feed.xml(), 'utf8'
  callback and callback()

render.compile_template = (filename, theme_path) ->
  filename = path.join theme_path, "#{filename}.jade"
  template = fs.readFileSync filename, 'utf8'
  jade.compile template, {filename: filename}

module.exports = render
