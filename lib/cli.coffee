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
render = require '../lib/render'

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

import_settings = ->
  directory.root 'settings.json', (top) ->
    # check if directory valid
    if top is null
      console.log 'using `catlog init` to initialize project directory'.error
      process.exit()

    global_settings = require '../assets/settings'
    local_settings = require path.join(top, 'settings.json')
    local_settings = _.clone _.defaults local_settings, global_settings
    # reset as relative path
    local_settings.source = path.join top, local_settings.source
    local_settings.destination = path.join top, local_settings.destination
    local_settings.theme_path = path.join top, "themes/#{local_settings.theme}"
    local_settings.plugin_path = path.join top, "plugins"
    return local_settings

create_article = (src, callback) ->
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

cmd_init = ->
  init = ->
    global_settings = require '../assets/settings'
    root = path.resolve __dirname, '..'
    src = global_settings.source
    dest = global_settings.destination
    fs.mkdirSync src
    fs.mkdirSync dest
    console.log 'creates a skeleton site with a basic set of templates'.info
    console.log 'copying plugins'.info
    fs.copy "#{root}/assets/plugins", 'plugins', ->
      console.log 'copying themes'.info
      fs.copy "#{root}/assets/themes", 'themes', ->
        console.log 'copying settings'.info
        fs.copy "#{root}/assets/settings.json", 'settings.json', ->
          console.log 'copying default blog content'.info
          fs.copy "#{root}/assets/examples", "#{src}/examples", ->
  if not fs.readdirSync('.').length
    init()
  else
    inquirer.prompt {
      type: 'confirm'
      name: 'ifProcess'
      message: 'Current directory not empty, do you really want to process?'
      default: false
    }, (answers) ->
      if answers.ifProcess
        init()

cmd_publish = ->
  create_article '', ->
    process.stdin.destroy()

cmd_build = (args) ->
  settings = import_settings()
  console.log 'copying theme'.info
  fs.copy "#{settings.theme_path}", "#{settings.destination}/theme", ->
    console.log 'pars markdown'.info
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

cmd_preview = (args) ->
  temp.mkdir 'catlog', (err, dirPath) ->
    console.log "create temp directory #{dirPath}".info
    settings = import_settings()
    settings.destination = dirPath
    settings.base_url = '/' # local server always use root
    console.log 'copy theme'.info
    fs.copy "#{settings.theme_path}", "#{settings.destination}/theme", ->
      settings.auto = args.auto
      console.log 'pars markdown'.info
      parser.parse settings, (env) ->
        console.log 'render markdown'.info
        render.render env
        # static file server
        if args.server isnt undefined and typeof args.server isnt 'boolean'
          port = args.server
        else
          port = settings.port
        server.run {path: settings.destination, port: port}

cmd_migrate = (p) ->
  directory.list p, ((src) ->
    fs.statSync(src).isFile() and path.extname(src) is '.md'
  ), ((srcs) ->
    async.eachSeries srcs, ((src, callback) ->
      create_article src, callback
    ), ->
      process.stdin.destroy()
  )

cmd_help = (cmd) ->
  if cmd
    command = _.find program.commands, (command) -> command._name is cmd
    command.outputHelp()
  else
    program.help()

program
  .version(require('../package.json').version)

program
  .command('init')
  .description('initialize project, create new directory before initialize')
  .action(cmd_init)

program
  .command('publish')
  .description('publish new article')
  .action(cmd_publish)

program
  .command('preview')
  .description('preview generated html files')
  .option('-s --server [port]', 'start local server')
  .option('-a --auto', 'watch for file change and auto update')
  .action(cmd_preview)

program
  .command('build')
  .description('build html files')
  .option('-s --server [port]', 'start local server')
  .option('-a --auto', 'watch for file change and auto update')
  .action(cmd_build)

program
  .command('migrate <path>')
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
