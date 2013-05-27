fs = require 'fs'
path = require 'path'
_ = require 'underscore'
async = require 'async'
directory = require './directory'
parser = require './parser'
render = require './render'
generator = {}

generator.generate = (settings, auto) ->
  envs = []
  settings = _.clone settings
  directory.traverse settings.source, (src) ->
    env = _.clone settings
    if fs.statSync(src).isFile() and path.extname(src) is '.md'
      env.src = src
      envs.push env
      parser.parse_post env

  settings.categories = parser.parse_categories envs
  @generate_posts envs, auto
  # generate index
  index_env = _.clone settings
  index_env.posts = envs
  @generate_list index_env, '/'
  # generate categories
  for category, posts of settings.categories
    categories_env = _.clone settings
    categories_env.posts = posts
    # FIXME how to locate category directory?
    @generate_list categories_env, category

generator.generate_post = (env, callback) ->
  parser.parse_post env
  render.render_post env, ->
    not fs.existsSync(path.dirname env.dest) and
      directory.mkdir_parent path.dirname(env.dest)
    fs.writeFileSync env.dest, env.post, 'utf8'
    callback and callback()

generator.generate_posts = (envs, auto, callback) ->
  # render post
  async.each envs, ((env, callback) =>
    render.render_post env, =>
      not fs.existsSync path.dirname env.dest and
        directory.mkdir_parent path.dirname env.dest
        fs.writeFileSync env.dest, env.post, 'utf8'
        callback()
        auto and fs.watchFile env.src, {persistent: true, interval: 1000}, =>
          @updater env
  ), (->
    console.log 'complete'
    callback and callback())

generator.generate_list = (env, to) ->
  render.render_list env
  fs.writeFileSync path.join(env.destination, to, 'index.html'), env.post, 'utf8'

generator.updater = (env) ->
  console.log 'update'
  @generate_post env

module.exports = generator
