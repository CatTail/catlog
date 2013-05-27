fs = require 'fs'
path = require 'path'
util = require 'util'
marked = require 'marked'
async = require 'async'
pygments = require 'pygments'
ejs = require 'ejs'
root = path.join __dirname, '..'
render = {}

marked.setOptions({
  gfm: true,
  tables: true,
  breaks: false,
  pedantic: false,
  sanitize: true,
  smartLists: true,
  langPrefix: 'highlight lang-',
#  highlight: (code, lang) ->
#    return code
})

render.render_post = (env, callback) ->
  # hack for pygment syntax async highlight
  tokens = marked.lexer env.post
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
    # ejs option
    env.filename = path.join root, "themes/#{env.theme}/post.ejs"
    template = fs.readFileSync env.filename, 'utf8'
    env.post = marked.parser tokens
    env.post = ejs.render template, env
    callback && callback env

render.render_list = (env) ->
  env.filename = path.join root, "themes/#{env.theme}/list.ejs"
  env.post = ejs.render fs.readFileSync(env.filename, 'utf8'), env
  return env

module.exports = render
