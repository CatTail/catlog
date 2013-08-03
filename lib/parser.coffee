# parser for site and article meta info
fs = require 'fs'
path = require 'path'
_ = require 'underscore'
async = require 'async'
directory = require './directory'
parser = {}

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
  srcs = directory.list site.source, (src) ->
    fs.statSync(src).isFile() and path.basename(src) is 'meta.json'
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
  callback and callback post

module.exports = parser
