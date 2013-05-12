var fs = require('fs')
  , path = require('path')
  , _ = require('underscore')
  , async = require('async')
  , directory = require('./directory')
  , parser = require('./parser')
  , render = require('./render')
  , generator = {};

generator.generate = function generate (settings) {
  var envs = []
    , index_env
    , categories_env
    , category;
  settings = _.clone(settings);
  directory.traverse(settings.source, function (src) {
    var env = _.clone(settings);
    if (fs.statSync(src).isFile() && path.extname(src) === '.md') {
      env.src = src;
      envs.push(env);
      parser.parse_post(env);
    }
  });
  settings.categories = parser.parse_categories(envs);
  this.generate_posts(envs);
  // generate index
  index_env = _.clone(settings);
  index_env.posts = envs;
  this.generate_list(index_env, '/');
  // generate categories
  for (category in settings.categories) {
    categories_env = _.clone(settings);
    categories_env.posts = settings.categories[category];
    // FIXME how to locate category directory?
    this.generate_list(categories_env, category);
  }
};

generator.generate_post = function generate_post (env, callback) {
  parser.parse_post(env);
  render.render_post(env, function () {
    !fs.existsSync(path.dirname(env.dest)) &&
      directory.mkdir_parent(path.dirname(env.dest));
    fs.writeFileSync(env.dest, env.post, 'utf8');
    callback && callback();
  });
};

generator.generate_posts = function generate_posts (envs, callback) {
  var that = this;
  // render post
  async.each(envs, function (env, callback) {
    render.render_post(env, function () {
      !fs.existsSync(path.dirname(env.dest)) &&
        directory.mkdir_parent(path.dirname(env.dest));
      fs.writeFileSync(env.dest, env.post, 'utf8');
      fs.watchFile(env.src, {persistent: true, interval: 1000}, function () {
        debugger;
        that.updater(env);
      });
      callback();
    });
  }, function () {
    console.log('complete');
    callback && callback();
  });
};

generator.generate_list = function generate_list (env, to) {
  render.render_list(env);
  fs.writeFileSync(path.join(env.destination, to, 'index.html'), env.post, 'utf8');
};

generator.updater = function updater (env) {
  console.log('update');
  this.generate_post(env);
};

module.exports = generator;
