fs = require 'fs'
path = require 'path'
_ = require 'underscore'
async = require 'async'
marked = require 'marked'
pygments = require 'pygments'
ejs = require 'ejs'
directory = require './directory'
parser = {}

marked.setOptions {
  gfm: true
  tables: true
  breaks: false
  pedantic: false
  sanitize: true
  smartLists: true
  langPrefix: 'highlight lang-'
}

parser.permalink_styles = {
  date: ':category/:year/:month/:day/:title/index.html'
  none: ':category/:title/index.html'
}

parser.parse = (site, callback) ->
  site.categories = []
  site.posts = []
  site.plugins = @parse_plugin site.plugin_path, site.plugins
  # date is the default permalink style
  site.permalink_style = @permalink_styles[site.permalink_style] or
    site.permalink_style or @permalink_styles.date
  directory.list site.source, ((src) ->
    fs.statSync(src).isFile() and path.extname(src) is '.md'
  ), ((srcs) =>
    async.each srcs, ((src, callback) =>
      post = @parse_post src, site.permalink_style, (post) ->
        # markdown content interpolation
        post.content = ejs.render post.content, {post: post, site: site}
        site.posts.push post
        if site.categories.indexOf(post.category) is -1
          site.categories.push post.category
        callback()
    ), ->
      callback(site)
  )

parser.parse_post = (src, permalink_style, callback) ->
  post = {}
  post.src = src
  post.title = path.basename path.dirname src
  post.category = path.basename path.dirname path.dirname src
  _.defaults post, require path.join(path.dirname(src), 'meta.json')
  [post.year, post.month, post.day] = post.date.split '-'
  post.permalink = permalink_style.replace(/:(\w+)/g, (match, item) ->
    return post[item.toLowerCase()]
  )
  @parse_markdown fs.readFileSync(src, 'utf8'), (content) ->
    post.content = content
    callback and callback post

parser.parse_markdown = (content, callback) ->
  tokens = marked.lexer content
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
    content = marked.parser tokens
    callback and callback(content)

parser.parse_plugin = (plugin_path, plugins) ->
  for plugin, config of plugins
    raw = fs.readFileSync path.join(plugin_path, "#{plugin}.html"), 'utf8'
    plugins[plugin] = ejs.render raw, config
  return plugins

module.exports = parser
