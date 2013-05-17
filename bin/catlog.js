#! /usr/bin/env node

var fs = require('fs')
  , path = require('path')
  , util = require('util')
  , exec = require('child_process').exec
  , _ = require('underscore')
  , program = require('commander')
  , ejs = require('ejs')
  , moment = require('moment')
  , server = require('../lib/server')
  , generator = require('../lib/generator')
  , root = path.resolve(__dirname, '..');

program
  .version('0.0.1')
//  .option('-c --config [path]', 'self defined configuration file')
  .option('-s --server [port]', 'start local server on port')
  .option('-a --auto', 'watch for file change and auto update');

program
  .command('init')
  .description('initialize project')
  .action(cmd_init);
program
  .command('post <title>')
  .description('generate post')
  .action(cmd_post)

program
  .command('generate')
  .description('generate assets and html files')
  .action(cmd_generate);

program
  .command('*')
  .description('Unknown command')
  .action(function () {
    console.log('Invalid command, see `catlog --help` for more info');
  });

program.parse(process.argv);

function cmd_init () {
  var settings = fs.readFileSync(path.join(root, 'assets/settings.json'));
  fs.writeFileSync('./settings.json', settings, 'utf8');
}

function cmd_post (title) {
  var global_settings = require('../settings')
    , local_settings = JSON.parse(fs.readFileSync('./settings.json', 'utf8'))
    , settings = _.defaults(local_settings, global_settings);

  var categories = fs.readdirSync(settings.source);
  console.log('category:');
  program.choose(categories, function (index, category) {
    program.prompt('author(blank to use default settings): ', function (author) {
      author = author || settings.author;
      var date = moment().format('YYYY-MM-DD');
      var time = moment().format('HH:mm:ss');
      // render
      var header = fs.readFileSync(path.join(root, 'assets/header.ejs'), 'utf8');
      header = ejs.render(header, {
        title: title, category: category, date: date, time: time, author: author
      });
      // create
      var basename = path.join(settings.source, category, title);
      fs.mkdirSync(basename);
      fs.writeFileSync(path.join(basename, title+'.md'), header, 'utf8');
      process.stdin.destroy();
    });
  });
};

function cmd_generate () {
  var global_settings = require('../settings')
    , local_settings = JSON.parse(fs.readFileSync('./settings.json', 'utf8'))
    , settings = _.defaults(local_settings, global_settings);

  if (program.server != null) {
    server.run({root: settings.destination, 
               port: program.server || settings.port});
  }
  
  generator.generate(settings, program.auto);
  // copy themes assets
  // FIXME
  exec(util.format('rm -r ./%s/themes/*', settings.destination), function () {
    exec(util.format('cp -rf %s/themes/%s %s;mv %s/%s %s/theme', 
                     root, settings.theme, settings.destination,
                     settings.destination, settings.theme, settings.destination));
  });
}
