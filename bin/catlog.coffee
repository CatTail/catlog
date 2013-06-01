#! /usr/bin/env coffee

fs = require 'fs'
path = require 'path'
util = require 'util'
exec = require('child_process').exec
_ = require 'underscore'
program = require 'commander'
ejs = require 'ejs'
moment = require 'moment'
async = require 'async'
server = require '../lib/server'
generator = require '../lib/generator'
root = path.resolve __dirname, '..'
current = process.cwd()

copyFileSync = (from, to) ->
  fs.writeFileSync to, fs.readFileSync(from, 'utf8'), 'utf8'

import_settings = ->
  global_settings = require '../settings'
  local_settings = require path.join(current, 'settings.json')
  _.defaults local_settings, global_settings

cmd_init = ->
  copyFileSync path.join(root, 'assets/settings.json'), './settings.json'
  exec "cp -r #{root}/themes themes"

cmd_post = (title) ->
  settings = import_settings()
  async.series([
    ((callback) ->
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
    category = results[0]
    author = results[1]
    date = moment().format 'YYYY-MM-DD'
    time = moment().format 'HH:mm:ss'
    meta = """
      {
        "title": "#{title}",
        "date": "#{date}",
        "time": "#{time}",
        "author": "#{author}"
      } 
      """
    basename = path.join settings.source, category, title
    fs.mkdirSync basename
    fs.writeFileSync path.join(basename, 'meta.json'), meta, 'utf8'
    fs.writeFileSync path.join(basename, 'index.md'), '', 'utf8'
    process.stdin.destroy()
  )

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
  generator.generate settings, program.auto

cmd_migrate = ->
  # using filename as post title


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
  .command('post <title>')
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
