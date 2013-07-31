fs = require 'fs'
path = require 'path'
exec = require('child_process').exec
_ = require 'underscore'
program = require 'commander'
moment = require 'moment'
async = require 'async'
server = require '../lib/server'
directory = require '../lib/directory'
parser = require '../lib/parser'
render = require '../lib/render'

import_settings = ->
  directory.root 'settings.json', (top) ->
    # check if directory valid
    if top is null
      throw 'using `catlog init` to initialize project directory'

    global_settings = require '../assets/settings'
    local_settings = require path.join(top, 'settings.json')
    local_settings = _.clone _.defaults local_settings, global_settings
    # reset as relative path
    local_settings.source = path.join top, local_settings.source
    local_settings.destination = path.join top, local_settings.destination
    local_settings.theme_path = path.join top, "themes/#{local_settings.theme}"
    local_settings.plugin_path = path.join top, "plugins"
    return local_settings

create_post = (src, callback) ->
  if (src)
    console.log "Original markdown file #{src}"
    content = fs.readFileSync src, 'utf8'
  settings = import_settings()
  async.series([
    ((callback) ->
      # permalink title
      program.prompt 'permalink title: ', (title) ->
        callback null, title
    ), ((callback) ->
      # post name
      program.prompt 'post name: ', (name) ->
        callback null, name
    ), ((callback) ->
      # category
      categories = fs.readdirSync settings.source
      categories.push('Add new category')
      console.log 'category:'
      program.choose categories, (index, category) ->
        if index is (categories.length-1)
          program.prompt 'category name: ', (category) ->
            fs.mkdirSync path.join(settings.source, category)
            callback null, category
        else
          callback null, category
    ), ((callback) ->
      # author
      program.prompt 'author(blank to use default settings): ', (author) ->
        callback null, author or settings.author
    )
  ], (err, results) ->
    # meta data
    title = results[0]
    name = results[1]
    category = results[2]
    author = results[3]
    date = moment().format 'YYYY-MM-DD'
    time = moment().format 'HH:mm:ss'
    meta = """
      {
        "name": "#{name}",
        "date": "#{date}",
        "time": "#{time}",
        "author": "#{author}"
      } 
      """
    basename = path.join settings.source, category, title
    fs.mkdirSync basename
    fs.writeFileSync path.join(basename, 'meta.json'), meta, 'utf8'
    fs.writeFileSync path.join(basename, 'index.md'), content or '', 'utf8'
    callback && callback()
  )

cmd_init = ->
  exec "cp -r #{path.resolve __dirname, '..'}/assets/* ."
  global_settings = require '../assets/settings'
  fs.mkdirSync global_settings.source
  fs.mkdirSync global_settings.destination

cmd_post = ->
  create_post '', ->
    process.stdin.destroy()

cmd_generate = ->
  settings = import_settings()
  # copy themes assets
  exec "rm -rf #{settings.destination}/theme", ->
    exec "cp -r #{settings.theme_path} #{settings.destination}/theme", ->
      # parse, render markdowns
      settings.auto = program.auto
      parser.parse settings, (env) ->
        render.render env
  # static file server
  if program.server isnt undefined
    port = if typeof program.server is 'boolean' then settings.port else program.server
    server.run {path: settings.destination, port: port}

cmd_migrate = (p) ->
  directory.list p, ((src) ->
    fs.statSync(src).isFile() and path.extname(src) is '.md'
  ), ((srcs) ->
    async.eachSeries srcs, ((src, callback) ->
      create_post src, callback
    ), ->
      process.stdin.destroy()
  )

program
  .version(require('../package.json').version)
  .option('-s --server [port]', 'start local server on port')
  .option('-a --auto', 'watch for file change and auto update')

program
  .command('init')
  .description('initialize project')
  .action(cmd_init)

program
  .command('migrate <path>')
  .description('migrate already exist markdown file into catlog accepted 
directory construct')
  .action(cmd_migrate)

program
  .command('post')
  .description('generate post')
  .action(cmd_post)

program
  .command('generate')
  .description('generate assets and html files')
  .action(cmd_generate)

program
  .command('*')
  .description('Unknown command')
  .action -> console.log 'Invalid command, see `catlog --help` for more info'

program.parse process.argv
