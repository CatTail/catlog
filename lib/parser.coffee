fs = require 'fs'
path = require 'path'
_ = require 'underscore'
directory = require './directory'
parser = {}
cwd = process.cwd()

parser.parse = (env) ->
  env.categories = []
  env.posts = []
  directory.traverse env.source, (src) =>
    if fs.statSync(src).isFile() and path.extname(src) is '.md'
      env.posts.push(post = @parse_post src, env)
      if env.categories.indexOf(post.category) is -1
        env.categories.push post.category
  return env

parser.permalink_styles = {
  date: ':category/:year/:month/:day/:title.html'
  none: ':category/:title.html'
}

parser.parse_post = (src, env) ->
  post = {}
  post.src = src
  post.content = fs.readFileSync src, 'utf8'
  post.title = path.basename path.dirname src
  post.category = path.basename path.dirname path.dirname src
  meta = require path.join(cwd, path.dirname(src), 'meta.json')
  post = _.defaults meta, post
  [post.year, post.month, post.day] = post.date.split '-'
  # date is the default permalink style
  env.permalink_style = @permalink_styles[env.permalink_style] or
    env.permalink_style or @permalink_styles.date
  post.permalink = env.permalink_style.replace(/:(\w+)/g, (match, item) ->
    return post[item.toLowerCase()]
  )
  post.dest = path.join env.destination, post.permalink
  return post

module.exports = parser
