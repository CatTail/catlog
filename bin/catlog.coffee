#! /usr/bin/env coffee

fs = require 'fs'
path = require 'path'
util = require 'util'
exec = require('child_process').exec
_ = require 'underscore'
program = require 'commander'
moment = require 'moment'
async = require 'async'
server = require '../lib/server'
directory = require '../lib/directory'
parser = require '../lib/parser'
render = require '../lib/render'
root = path.resolve __dirname, '..'
current = process.cwd()

copyFileSync = (from, to) ->
  fs.writeFileSync to, fs.readFileSync(from, 'utf8'), 'utf8'

import_settings = ->
  global_settings = require '../assets/settings'
  local_settings = require path.join(current, 'settings.json')
  _.defaults local_settings, global_settings

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
  exec "cp -r #{root}/assets/* ."

cmd_post = ->
  create_post()

cmd_generate = ->
  settings = import_settings()
  # copy themes assets
  exec "rm -rf #{settings.destination}/theme", ->
    exec "cp -r themes/#{settings.theme} #{settings.destination}/theme"
  # static file server
  if program.server isnt null
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
  .version('0.0.1')
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
