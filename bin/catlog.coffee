#! /usr/bin/env coffee

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
  top = directory.root()
  # check if directory valid
  if top is null
    throw 'using `catlog init` to initialize project directory'

  global_settings = require '../assets/settings'
  local_settings = require path.join(top, 'settings.json')
  _.defaults local_settings, global_settings
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
    category = results[1]
    author = results[2]
    date = moment().format 'YYYY-MM-DD'
    time = moment().format 'HH:mm:ss'
    meta = """
      {
        "author": "#{author}",
        "date": "#{date}",
        "time": "#{time}"
      } 
      """
    basename = path.join settings.source, category, title
    fs.mkdirSync basename
    fs.writeFileSync path.join(basename, 'meta.json'), meta, 'utf8'
    fs.writeFileSync path.join(basename, 'index.md'), content or '', 'utf8'
    process.stdin.destroy()
    callback && callback()
  )

cmd_init = ->
  exec "cp -r #{path.resolve __dirname, '..'}/assets/* ."
  global_settings = require '../assets/settings'
  fs.mkdirSync global_settings.source
  fs.mkdirSync global_settings.destination

cmd_post = ->
  create_post()

cmd_generate = ->
  settings = import_settings()
  # copy themes assets
  exec "rm -rf #{settings.destination}/theme", ->
    exec "cp -r #{settings.theme_path} #{settings.destination}/theme"
  # static file server
  if program.server isnt undefined
    server.run {
      path: settings.destination, port: program.server or settings.port}
  # parse, render markdowns
  _.defaults settings, program.auto
  parser.parse settings, (env) ->
    render.render env

cmd_migrate = (p) ->
  srcs = directory.list p, (src) ->
    fs.statSync(src).isFile() and path.extname(src) is '.md'
  async.eachSeries srcs, (src, callback) ->
    create_post src, callback

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
