fs = require 'fs'
path = require 'path'
_ = require 'underscore'
async = require 'async'
marked = require 'marked'
pygments = require 'pygments'
mustache = require 'mustache'
directory = require './directory'
parser = {}
cwd = process.cwd()

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
  date: ':category/:year/:month/:day/:title.html'
  none: ':category/:title.html'
}

parser.parse = (env, callback) ->
  env.categories = []
  env.posts = []
  env.plugins = @parse_plugin env.plugins
  # date is the default permalink style
  env.permalink_style = @permalink_styles[env.permalink_style] or
    env.permalink_style or @permalink_styles.date
  srcs = directory.list env.source, (src) ->
    fs.statSync(src).isFile() and path.extname(src) is '.md'
  async.each srcs, ((src, callback) =>
    post = @parse_post src, env.permalink_style, (post) ->
      env.posts.push post
      if env.categories.indexOf(post.category) is -1
        env.categories.push post.category
      callback()
  ), ->
    callback env

parser.parse_post = (src, permalink_style, callback) ->
  post = {}
  post.src = src
  post.title = path.basename path.dirname src
  post.category = path.basename path.dirname path.dirname src
  _.defaults post, require path.join(cwd, path.dirname(src), 'meta.json')
  [post.year, post.month, post.day] = post.date.split '-'
  post.permalink = permalink_style.replace(/:(\w+)/g, (match, item) ->
    return post[item.toLowerCase()]
  )
  @parse_markdown fs.readFileSync(src, 'utf8'), (heading, content) ->
    post.heading = heading
    post.content = content
    callback and callback post

parser.parse_markdown = (content, callback) ->
  heading = null
  tokens = marked.lexer content
  async.forEach tokens, ((token, callback) ->
    if token.type is 'code'
      pygments.colorize token.text, token.lang, 'html', ((data) ->
        token.escaped = true
        token.text = data
        callback()
      ), {'P': 'nowrap=true'}
    else if token.type is 'heading' and heading is null
      heading = token.text
      callback()
    else
      callback()
  ), ->
    content = marked.parser tokens
    callback and callback(heading, content)

parser.parse_plugin = (plugins) ->
  for plugin, config of plugins
    raw = fs.readFileSync "plugins/#{plugin}.html", 'utf8'
    mustache.render raw, config

module.exports = parser
