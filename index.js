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

function updater (filename, template) {
  render_post(filename, template);
}

var main = function main () {
  var default_settings = require('./settings')
    , settings = _.defaults({}/* global_settings */, default_settings)
    , envs = [];

  directory.traverse(settings.source, function (dir) {
    var newDir, env = _.clone(settings);
    if (dir !== settings.source) {
      if (fs.statSync(dir).isDirectory()) {
        newDir = dir.replace(settings.source, settings.destination);
        !fs.existsSync(newDir) && fs.mkdirSync(newDir);
      } else {
        if (path.extname(dir) === '.md') {
          env.fullpath = dir;
          parser.parse_post(env);
          render.render_post(env, function () {
            envs.push(env);
          });
          fs.watchFile(dir, {persistent: true, interval: 1000}, function () {
//            updater(dir, template);
          });
        }
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
