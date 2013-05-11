var fs = require('fs')
  , util = require('util')
  , exec = require('child_process').exec
  , path = require('path')
  , parser = require('./lib/parser')
  , render = require('./lib/render')
  , directory = require('./lib/directory')
  , server = require('./lib/server')
//  , ncp = require('ncp')
  , _ = require('underscore');

var gen_post = function gen_post (env) {
  parser.parse_post(env);
  render.render_post(env, function () {
    !fs.existsSync(path.dirname(env.destination)) &&
      directory.mkdir_parent(path.dirname(env.destination));
    fs.writeFileSync(env.destination, env.post, 'utf8');
  });
};

var updater = function updater (env) {
  console.log('update');
  gen_post(env);
};

var main = function main () {
  var default_settings = require('./settings')
    , settings = _.defaults({}/* global_settings */, default_settings)
    , envs = [];

  directory.traverse(settings.source, function (fullpath) {
    var env = _.clone(settings);
    if (fs.statSync(file).isFile()) {
      if (path.extname(file) === '.md') {
        envs.push(env);
        env.source = fullpath;
        gen_post(env);
        fs.watchFile(file, {persistent: true, interval: 1000}, function () {
          updater(env);
        });
      }
    }
  });
  // render index
  /*
  var options;
  (options = _.clone(settings)).section = ejs.render(list_template, {articles: envs});
  fs.writeFileSync(settings.destination+'/index.html', ejs.render(template, options), 'utf8');
 */
  // copy themes assets
  // FIXME
  exec(util.format('cp -r ./themes/%s %s;mv %s/%s %s/theme', 
                   settings.theme, settings.destination, settings.destination, 
                   settings.theme, settings.destination));
//  ncp('themes/'+settings.theme, settings.destination, function () {});
  server.run({root: settings.destination, port: settings.port});
};

main();
