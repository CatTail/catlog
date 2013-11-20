fs = require 'fs-extra'
path = require 'path'
_ = require 'underscore'
program = require 'commander'
inquirer = require 'inquirer'
colors = require 'colors'
moment = require 'moment'
async = require 'async'
temp = require 'temp'
server = require '../lib/server'
directory = require '../lib/directory'
parser = require '../lib/parser'
render = require '../lib/render.coffee'
watch = require 'node-watch'

colors.setTheme({
  silly: 'rainbow'
  input: 'grey'
  verbose: 'cyan'
  prompt: 'grey'
  info: 'green'
  data: 'grey'
  help: 'cyan'
  warn: 'yellow'
  debug: 'blue'
  error: 'red'
})

import_settings = (to='.') ->
  to = path.resolve to
  top = directory.root to, "settings.json"
  if top is null
    # check if directory valid
    console.log 'use `catlog init [to]` to initialize project directory'.error
    process.exit()

  global_settings = require '../assets/settings'
  local_settings = require path.join(top, 'settings.json')
  local_settings = _.clone _.defaults local_settings, global_settings
  # reset as relative path
  local_settings.source = path.join top, local_settings.source
  local_settings.destination = path.join top, local_settings.destination
  local_settings.theme_path = path.join top, "themes"
  local_settings.plugin_path = path.join top, "plugins"
  # asset_url default to base_url
  local_settings.asset_url = local_settings.base_url
  return local_settings

create_post = (src, to, callback) ->
  if (src)
    console.log "Original markdown file #{src}"
    content = fs.readFileSync src, 'utf8'
  settings = import_settings to

  categories = fs.readdirSync settings.source
  newCategory = 'Add new category'
  categories.push newCategory
  questions = [
    {
      type: 'input'
      name: 'name'
      message: 'write your article name'
    }
    {
      type: 'list'
      name: 'category'
      message: 'choose article category'
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
    console.log 'created a new article directory below contents folder.'.prompt
    console.log "edit article in #{settings.source}/#{category}/#{title}/index.md".prompt
    callback and callback()

cmd_init = (to='.', options) ->
  init = ->
    global_settings = require '../assets/settings'
    assets = path.resolve __dirname, '../assets'
    to = path.resolve to
    src = path.join to, global_settings.source
    dest = path.join to, global_settings.destination

    console.log 'creates site skeleton structure'.info

    if not fs.existsSync(src)
      fs.mkdirSync(src)
      console.log 'copying default blog content'.info
      fs.copy "#{assets}/assets/examples", "#{src}/examples"
    else
      console.log "#{src} exist, leave without touch".warn

    if not fs.existsSync(dest)
      fs.mkdirSync(dest)
    else
      console.log "#{dest} exist, leave without touch".warn

    assets = [
      ["#{assets}/plugins", "#{to}/plugins"]
      ["#{assets}/themes", "#{to}/themes"]
      ["#{assets}/settings.json", "#{to}/settings.json"]
    ]
    for asset in assets
      if not fs.existsSync asset[1]
        console.log "copy #{asset[1]}".info
        fs.copy asset[0], asset[1]
      else
        console.log "#{asset[1]} exist, leave without touch".warn

  try
    if not fs.readdirSync(to).length or options.force
      init()
    else
      # directory not empty
      inquirer.prompt {
        type: 'confirm'
        name: 'ifProcess'
        message: 'Current directory not empty, do you really want to process?'
        default: false
      }, (answers) ->
        if answers.ifProcess
          init()
  catch err
    console.log "Directory not exit".error


cmd_publish = (to) ->
  create_post '', to, ->
    process.stdin.destroy()


build = (settings, callback) ->
  parser.parse settings, (env) ->
    render.render env


cmd_build = (to='.', args) ->
  settings = import_settings to
  if args.assetUrl
    settings.asset_url = args.assetUrl
  console.log 'copying theme'.info
  fs.copy "#{settings.theme_path}", "#{settings.destination}/themes", ->
    console.log 'parse markdown'.info
    settings.auto = args.auto
    parser.parse settings, (env) ->
      console.log 'render html'.info
      render.render env
      # static file server
      if args.server isnt undefined
        if typeof args.server is 'boolean'
          port = settings.port
        else
          port = args.server
        server.run {path: settings.destination, port: port}
      # auto build
      if args.auto
        watch settings.source, {followSymLinks: true}, ->
          build settings


cmd_preview = (to='.', args) ->
  temp.mkdir 'catlog', (err, dirPath) ->
    console.log "create temp directory #{dirPath}".info
    settings = import_settings to
    settings.destination = dirPath
    settings.base_url = '/' # local server always use root
    console.log 'copy theme'.info
    fs.copy "#{settings.theme_path}", "#{settings.destination}/themes", ->
      settings.auto = args.auto
      console.log 'parse markdown'.info
      parser.parse settings, (env) ->
        console.log 'render markdown'.info
        render.render env
        # static file server
        if args.server isnt undefined and typeof args.server isnt 'boolean'
          port = args.server
        else
          port = settings.port
        server.run {path: settings.destination, port: port}
        # auto build
        if args.auto
          watch settings.source, {followSymLinks: true}, ->
            build settings

cmd_migrate = (from, to) ->
  srcs = directory.list from, (src) ->
    fs.statSync(src).isFile() and path.extname(src) is '.md'

  async.eachSeries srcs, ((src, callback) ->
    create_post src, to, callback
  ), ->
    process.stdin.destroy()

cmd_help = (cmd) ->
  if cmd
    command = _.find program.commands, (command) -> command._name is cmd
    command.outputHelp()
  else
    program.help()

program
  .version(require('../package.json').version)

program
  .command('init [to]')
  .description('initialize project, create new directory before initialize')
  .option('-f --force', 'force initialize on directory not empty')
  .action(cmd_init)

program
  .command('publish [to]')
  .description('publish new article')
  .action(cmd_publish)

program
  .command('preview [to]')
  .description('preview generated html files')
  .option('-s --server [port]', 'start local server')
  .option('-a --auto', 'watch for file change and auto update')
  .action(cmd_preview)

program
  .command('build [to]')
  .description('build html files')
  .option('-u --asset-url [url]', 'use self defined asset url')
  .option('-s --server [port]', 'start local server')
  .option('-a --auto', 'watch for file change and auto update')
  .action(cmd_build)

program
  .command('migrate <from> [to]')
  .description('migrate exist markdown file into project')
  .action(cmd_migrate)

program
  .command('help [cmd]')
  .description('display command description')
  .action(cmd_help)

program
  .command('*')
  .description('unknown')
  .action(program.help)

program.parse process.argv

if program.args.length is 0
  program.help()
