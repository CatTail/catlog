fs = require 'fs'
path = require 'path'
parser = {}

parser.parse_categories = (envs) ->
  categories = {}
  for env in envs
    if categories[env.category]
      categories[env.category].push(env)
    else
      categories[env.category] = [env]
    env.categories = categories
  return categories

parser.parse_post = (env) ->
  post = fs.readFileSync env.src, 'utf8'
  # parse variables
  match = post.match /^\s*\/\*\s*([^\0]*?)\*\//
  if match
    post = post.slice(match[0].length).trim()
    for option in match[1].trim().split(/\s*\n\s*/)
      [key, value] = option.split /\s*:\s*/
      env[key.toLowerCase()] = value

  [env.year, env.monty, env.day] = env.date.split '-'
  @parse_permalink env
  env.dest = path.join env.destination, env.permalink
  env.post = post
  

parser.permalink_styles =
  date: ':category/:year/:month/:day/:title.html'
  none: ':category/:title.html'

parser.parse_permalink = (env) ->
  # date is the default permalink style
  env.permalink_style = @permalink_styles[env.permalink_style] or
    env.permalink_style or @permalink_styles.date

  env.permalink = env.permalink_style.replace(/:(\w+)/g, (match, item) ->
    return env[item.toLowerCase()]
  )

module.exports = parser
