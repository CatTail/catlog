fs = require 'fs-extra'
path = require 'path'
_ = require 'underscore'
async = require 'async'
engine = {
  ejs: require 'ejs'
  jade: require 'jade'
}
directory = require './directory'
rss = require 'rss'
render = {}

render.render = (site, callback) ->
  site.plugins = @render_plugin site.plugin_path, site.plugins
  for post in site.posts
    handler = require "./handler/#{post.type or 'default'}"
    handler.render post
  # main page
  src = path.join site.theme_path, site.theme, 'index'
  dest = path.join site.destination, 'index.html'
  @render_file src, dest, site
  # category page
  for category in site.categories
    src = path.join site.theme_path, site.theme, 'list'
    dest = path.join site.destination, category, 'index.html'
    context = _.defaults {}, site
    context.posts = (post for post in site.posts when post.category is category)
    @render_file src, dest, context
  @render_feed site
  callback and callback()

render.render_file = (src, dest, context) ->
  dir = path.dirname src
  type = path.basename src
  # use index.html if permalink don't have filename
  dest = path.join(dest, if path.extname dest then '' else 'index.html')
  for file in fs.readdirSync dir
    if file.indexOf(type) is 0
      format = path.extname(file).slice(1)
      filename = "#{src}.#{format}"
      raw = fs.readFileSync filename, 'utf8'
      html = engine[format].render raw, _.defaults({filename: filename}, context)
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
    plugins[plugin] = engine.ejs.render raw, config
  return plugins

module.exports = render
