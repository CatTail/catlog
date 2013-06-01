fs = require 'fs'
path = require 'path'
_ = require 'underscore'
cwd = process.cwd()
parser = {}

parser.parse_post = (env) ->
  env.post = fs.readFileSync env.src, 'utf8'
  env.title = path.basename path.dirname env.src
  env.category = path.basename path.dirname path.dirname env.src
  _.defaults env, require path.join(cwd, path.dirname(env.src), 'meta.json')
  [env.year, env.monty, env.day] = env.date.split '-'
  @parse_permalink env
  env.dest = path.join env.destination, env.permalink

parser.permalink_styles = {
  date: ':category/:year/:month/:day/:title.html'
  none: ':category/:title.html'
}

parser.parse_permalink = (env) ->
  # date is the default permalink style
  env.permalink_style = @permalink_styles[env.permalink_style] or
    env.permalink_style or @permalink_styles.date

  env.permalink = env.permalink_style.replace(/:(\w+)/g, (match, item) ->
    return env[item.toLowerCase()]
  )

parser.parse_categories = (envs) ->
  categories = {}
  for env in envs
    if categories[env.category]
      categories[env.category].push(env)
    else
      categories[env.category] = [env]
    env.categories = categories
  return categories

module.exports = parser
