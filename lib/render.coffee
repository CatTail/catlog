fs = require 'fs'
path = require 'path'
_ = require 'underscore'
async = require 'async'
jade = require 'jade'
ejs = require 'ejs'
directory = require './directory'
parser = require './parser'
rss = require 'rss'
exec = require('child_process').exec
render = {}

render.render = (site, callback) ->
  fn_post = @compile_template 'post', site.theme_path
  fn_index = @compile_template 'index', site.theme_path
  fn_list = @compile_template 'list', site.theme_path
  site.plugins = @render_plugin site.plugin_path, site.plugins
  async.forEach site.posts, ((post, callback) =>
    dest = path.join(site.destination, post.permalink)
    dest_dir = path.dirname dest
    if post.type is 'html' # copy raw type assets
      @render_raw path.dirname(post.src), dest_dir, callback
    else
      # copy post assets
      src_dir = path.join path.dirname(post.src), 'assets'
      exec "cp -r #{src_dir} #{dest_dir}"
      # render
      # markdown content interpolation
      post.content = ejs.render post.content, {post: post, site: site}
      @render_file fn_post, {post: post, site: site}, dest, callback
      # auto change detect
      if site.auto
        fs.watchFile post.src, {persistent: true, interval: 1000}, =>
          console.log 'update'
          parser.parse_post post.src, site.permalink_style, (post) =>
            post.content = ejs.render post.content, {post: post, site: site}
            @render_file fn_post, {site: site, post: post}, dest
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
  # FIXME see https://github.com/caolan/async/pull/272
  if not fs.existsSync path.dirname dest
    directory.mkdir_parent path.dirname(dest), null, ->
      fs.writeFileSync dest, html, 'utf8'
      callback and callback()
  else
    fs.writeFileSync dest, html, 'utf8'
    callback and callback()

render.render_raw = (src, dest, callback) ->
  if not fs.existsSync dest
    directory.mkdir_parent dest, null, ->
      exec "cp -r #{src}/* #{dest}", ->
        callback and callback()
  else
    exec "cp -r #{src}/* #{dest}", ->
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

render.render_plugin = (plugin_path, plugins) ->
  for plugin, config of plugins
    raw = fs.readFileSync path.join(plugin_path, "#{plugin}.html"), 'utf8'
    plugins[plugin] = ejs.render raw, config
  return plugins

module.exports = render
