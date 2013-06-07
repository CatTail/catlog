fs = require 'fs'
path = require 'path'
_ = require 'underscore'
async = require 'async'
jade = require 'jade'
directory = require './directory'
parser = require './parser'
RSS = require 'rss'
render = {}

render.render = (site, callback) ->
  @site = site
  @fn_post = @compile_template 'post'
  @fn_index = @compile_template 'index'
  @fn_list = @compile_template 'list'
  async.forEach site.posts, ((post, callback) =>
    @render_post post, site, callback
    site.auto and fs.watchFile post.src, {persistent: true, interval: 1000}, =>
      console.log 'update'
      @render_post post, site
  ), =>
    @render_index site
    for category in site.categories
      posts = (post for post in site.posts when post.category is category)
      @render_list posts, site, category
    @render_feed site
    callback and callback()

render.render_post = (post, site, callback) ->
  context = {post: post, site: site}
  html = @fn_post context
  dest = path.join(site.destination, post.permalink)
  if not fs.existsSync path.dirname dest
    directory.mkdir_parent path.dirname dest
  fs.writeFileSync dest, html, 'utf8'
  callback and callback()

render.render_index = (site, callback) ->
  context = {site: site, posts: site.posts}
  html = @fn_index context
  fs.writeFileSync path.join(site.destination, 'index.html'), html, 'utf8'
  callback and callback()

render.render_list = (posts, site, dest, callback) ->
  context = {site: site, posts: posts}
  html = @fn_list context
  fs.writeFileSync path.join(site.destination, dest, 'index.html'), html, 'utf8'
  callback and callback()

render.render_feed = (site, callback) ->
  feed = new RSS {
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

render.compile_template = (filename) ->
  filename = "themes/#{@site.theme}/#{filename}.jade"
  template = fs.readFileSync filename, 'utf8'
  jade.compile template, {filename: filename}

module.exports = render
