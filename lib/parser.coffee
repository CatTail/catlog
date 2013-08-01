fs = require 'fs'
path = require 'path'
_ = require 'underscore'
async = require 'async'
marked = require 'marked'
directory = require './directory'
parser = {}

marked.setOptions {
  gfm: true
  tables: true
  breaks: false
  pedantic: false
  sanitize: true
  smartLists: true
  langPrefix: ''
}

parser.permalink_styles = {
  date: ':category/:year/:month/:day/:title/:index.html'
  none: ':category/:title/:index.html'
}

parser.parse = (site, callback) ->
  site.categories = []
  site.posts = []
  # date is the default permalink style
  site.permalink_style = @permalink_styles[site.permalink_style] or
    site.permalink_style or @permalink_styles.date
  directory.list site.source, ((src) ->
    fs.statSync(src).isFile() and path.basename(src) is 'meta.json'
  ), ((srcs) =>
    async.each srcs, ((src, callback) =>
      @parse_post src, site.permalink_style, (post) =>
        site.posts.push post
        callback and callback()
    ), ->
      # sort
      site.posts.sort (a, b) ->
        new Date("#{b.date} #{b.time}") - new Date("#{a.date} #{a.time}")
      # categories
      for post in site.posts
        if site.categories.indexOf(post.category) is -1
          site.categories.push post.category
      callback(site)
  )

parser.parse_post = (src, permalink_style, callback) ->
  post = {}
  post.src = path.join path.dirname(src), 'index.md'
  post.title = path.basename path.dirname src
  post.category = path.basename path.dirname path.dirname src
  _.defaults post, require path.join(path.dirname(src), 'meta.json')
  post.index = post.index or 'index'
  [post.year, post.month, post.day] = post.date.split '-'
  post.permalink = permalink_style.replace(/:(\w+)/g, (match, item) ->
    return post[item.toLowerCase()]
  )
  if not post.type # default markdown type
    @parse_markdown fs.readFileSync(post.src, 'utf8'), (content) ->
      post.content = content
      callback and callback post
  else
    callback and callback post

parser.parse_markdown = (content, callback) ->
  content = marked.parser marked.lexer content
  callback and callback(content)

module.exports = parser
