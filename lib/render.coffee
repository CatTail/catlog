fs = require 'fs-extra'
path = require 'path'
_ = require 'underscore'
async = require 'async'
jade = require 'jade'
ejs = require 'ejs'
directory = require './directory'
rss = require 'rss'
render = {}

render.render = (site, callback) ->
  site.plugins = @render_plugin site.plugin_path, site.plugins
  for post in site.posts
    # markdown interpolation
    post.content = ejs.render post.content, post
    console.log post
    # render
    src = path.join post.theme_path, post.theme, 'post.jade'
    dest = path.join post.destination, post.permalink
    @render_file src, dest, post
    # assets
    assets = path.join path.dirname(post.src), 'assets'
    fs.copy "#{assets}", "#{path.dirname dest}/assets"

  src = path.join site.theme_path, site.theme, 'index.jade'
  dest = path.join site.destination, 'index.html'
  @render_file src, dest, site
  for category in site.categories
    src = path.join site.theme_path, site.theme, 'list.jade'
    dest = path.join site.destination, category, 'index.html'
    context = _.defaults {}, site
    context.posts = (post for post in site.posts when post.category is category)
    @render_file src, dest, context
  @render_feed site
  callback and callback()

render.compile_template = (template_path) ->
  template = fs.readFileSync template_path, 'utf8'
  jade.compile template, {filename: template_path}

render.render_file = (src, dest, context) ->
  html = @compile_template(src)(context)
  if not fs.existsSync path.dirname dest
    directory.mkdir_parent path.dirname(dest), null
  fs.writeFileSync dest, html, 'utf8'

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

render.render_plugin = (plugin_path, plugins) ->
  for plugin, config of plugins
    raw = fs.readFileSync path.join(plugin_path, "#{plugin}.html"), 'utf8'
    plugins[plugin] = ejs.render raw, config
  return plugins

module.exports = render
