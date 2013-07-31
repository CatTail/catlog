fs = require 'fs'
path = require 'path'
exec = require('child_process').exec
_ = require 'underscore'
program = require 'commander'
inquirer = require 'inquirer'
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

  categories = fs.readdirSync settings.source
  newCategory = 'Add new category'
  categories.push newCategory
  questions = [
    {
      type: 'input'
      name: 'name'
      message: 'write your post name'
    }
    {
      type: 'list'
      name: 'category'
      message: 'choose post category'
      choices: categories
    }
    {
      type: 'input'
      name: 'category'
      message: 'input new category name'
      validate: (value) -> value.length isnt 0
      filter: (category) ->
        fs.mkdirSync path.join(settings.source, category)
        return category
      when: (answers) ->
        return answers.category is newCategory
    }
    {
      type: 'input'
      name: 'title'
      message: 'input new permalink title'
      validate: (value) -> value.length isnt 0
    }
    {
      type: 'input'
      name: 'author'
      message: 'input author name'
      default: settings.author
    }
  ]
  inquirer.prompt questions, (answers) ->
    # meta data
    title = answers.title
    name = answers.name
    category = answers.category
    author = answers.author
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
    callback and callback()

cmd_init = ->
  exec "cp -r #{path.resolve __dirname, '..'}/assets/* ."
  global_settings = require '../assets/settings'
  fs.mkdirSync global_settings.source
  fs.mkdirSync global_settings.destination

cmd_post = ->
  create_post '', ->
    process.stdin.destroy()

cmd_build = ->
  settings = import_settings()
  console.log 'copying theme'
  exec "rm -rf #{settings.destination}/theme", ->
    exec "cp -r #{settings.theme_path} #{settings.destination}/theme", ->
      console.log 'parsing markdown'
      settings.auto = program.auto
      parser.parse settings, (env) ->
        console.log 'rendering html'
        render.render env
  # static file server
  if program.server isnt undefined
    port = if typeof program.server is 'boolean' then settings.port else program.server
    server.run {path: settings.destination, port: port}

cmd_preview = ->
  dest = path.join '/tmp', parseInt(Math.random()*1000, 10)+''
  fs.mkdirSync dest
  settings = import_settings()
  console.log 'copying theme'
  exec "rm -rf #{settings.destination}/theme", ->
    exec "cp -r #{settings.theme_path} #{settings.destination}/theme", ->
      settings.auto = program.auto
      console.log 'parsing markdown'
      parser.parse settings, (env) ->
        console.log 'rendering markdown'
        render.render env
  # static file server
  if program.server isnt undefined and typeof program.server isnt 'boolean'
    port = program.server
  else
    port = settings.port
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

help_init = """
- catlog init 

usage: catlog init
	
initialize a skeleton site,before it,you should make a new directory to hold it.

example:
	   
create a new site in your home directory

    $ mkdir ~/my-blog
    $ catlog init
"""
help_post = """
- catlog post

usage: catlog post

add a new blog, then you will need to provide some info for it, for example, postname、category、permalink title、author.
"""
help_preview = """
- catlog preview

usage:catlog preview [options]

options:

  -p, --port [port]             port to run server on (defaults to 8080)
  
  -a, --author 					 the default author name
  
  -t, --theme					 the site theme (defaults to came)


  all options can also be set in the settings file, include the plugin、 site_title、 source path、 destination path。

examples:

  preview using a setting file (assuming settings.json is found in working directory):
  $ catlog preview
"""
help_build = """
- catlog build
"""
cmd_help = (cmd) ->
  switch cmd
    when 'init' then console.log help_init
    when 'post' then console.log help_post
    when 'build' then console.log help_build
    when 'preview' then console.log help_preview
    else program.help()


program
  .version(require('../package.json').version)
  .option('-s --server [port]', 'start local server')
  .option('-a --auto', 'watch for file change and auto update')

program
  .command('init')
  .description('initialize project')
  .action(cmd_init)

program
  .command('migrate <path>')
  .description('migrate exist markdown file into project')
  .action(cmd_migrate)

program
  .command('post')
  .description('create post')
  .action(cmd_post)

program
  .command('build')
  .description('build html files')
  .action(cmd_build)

program
  .command('preview')
  .description('preview generated html files')
  .action(cmd_preview)

program
  .command('help [cmd]')
  .description('display command description')
  .action(cmd_help)

program.parse process.argv
