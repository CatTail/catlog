var fs = require('fs')
  , util = require('util')
  , exec = require('child_process').exec
  , path = require('path')
  , async = require('async')
  , parser = require('./lib/parser')
  , render = require('./lib/render')
  , directory = require('./lib/directory')
  , server = require('./lib/server')
//  , ncp = require('ncp')
  , _ = require('underscore');

var gen_post = function gen_post (env, callback) {
  parser.parse_post(env);
  render.render_post(env, function () {
    !fs.existsSync(path.dirname(env.dest)) &&
      directory.mkdir_parent(path.dirname(env.dest));
    fs.writeFileSync(env.dest, env.post, 'utf8');
    callback && callback();
  });
};

var updater = function updater (env) {
  console.log('update');
  gen_post(env);
};

var main = function main () {
  var default_settings = require('./settings')
    , settings = _.defaults({}/* global_settings */, default_settings)
    , categories
    , envs = [];

  directory.traverse(settings.source, function (src) {
    var env = _.clone(settings);
    if (fs.statSync(src).isFile() && path.extname(src) === '.md') {
      env.src = src;
      envs.push(env);
      parser.parse_post(env);
    }
  });
  categories = parser.parse_categories(envs);
  // render post
  async.each(envs, function (env, callback) {
    render.render_post(env, function () {
      !fs.existsSync(path.dirname(env.dest)) &&
        directory.mkdir_parent(path.dirname(env.dest));
      fs.writeFileSync(env.dest, env.post, 'utf8');
      fs.watchFile(env.src, {persistent: true, interval: 1000}, function () {
        updater(env);
      });
      callback();
    });
  }, function () {
    console.log('complete');
  });
  // render index
  var env = _.clone(settings);
  env.articles = envs;
  env.categories = categories;
  render.render_list(env);
  fs.writeFileSync(env.destination+'/index.html', env.post, 'utf8');
  // copy themes assets
  // FIXME
  exec(util.format('rm -r ./%s/themes/*', settings.destination), function () {
    exec(util.format('cp -rf ./themes/%s %s;mv %s/%s %s/theme', 
                     settings.theme, settings.destination, settings.destination, 
                     settings.theme, settings.destination));
  });
//  ncp('themes/'+settings.theme, settings.destination, function () {});
  server.run({root: settings.destination, port: settings.port});
};

main();
