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
  site.posts = []
  site.categories = []
  # date is default permalink style
  site.permalink_style = @permalink_styles[site.permalink_style] or
    site.permalink_style or @permalink_styles.date
  srcs = directory.list site.source, (src) ->
    fs.statSync(src).isFile() and path.basename(src) is 'meta.json'
  # parse meta
  for src in srcs
    post = {}
    _.defaults post, require(path.join(path.dirname(src), 'meta.json')), site
    post.src = path.join path.dirname(src), 'index.md'
    post.title = path.basename path.dirname src
    post.category = path.basename path.dirname path.dirname src
    post.index = post.index or 'index'
    [post.year, post.month, post.day] = post.date.split '-'
    post.permalink = post.permalink_style.replace /:(\w+)/g, (match, item) ->
      return post[item.toLowerCase()]
    site.posts.push post
    # categories
    if site.categories.indexOf(post.category) is -1
      site.categories.push post.category
  # sort by date
  # TODO add sort feature
  site.posts.sort (a, b) ->
    new Date("#{b.date} #{b.time}") - new Date("#{a.date} #{a.time}")
  # parse content
  async.each site.posts, ((post, callback) =>
    handler = require "./handler/#{post.type or 'default'}"
    handler.parse post, ->
      callback()
    #console.log post
    #handler.parse fs.readFileSync(post.src, 'utf8'), (context) =>
      #for key, val of context
        #post[key] = val
      #callback()
  ), ->
    callback site

module.exports = parser
