var fs = require('fs').readFileSync;
var path = require('path');

var parser = {};

parser.parse_post = function (fullpath, env) {
  var post, match;
  env.fullpath = fullpath;
  post = readFileSync(fullpath, 'utf8');
  // parse post variables
  match = post.match(/^\s*\/\*\s*([^\0]*?)\*\//);
  if (match) {
    post = post.slice(match[0].length).trim();
    match[1].trim().split(/\s*\n\s*/).forEach(function (option) {
      option = option.split(/\s*:\s*/);
      env[option[0]] = option[1];
    });
  }
  this.parse_permalink(env);
  return post;
}

parser.parse_permalink = function (env) {
  var permalink_style;
  env.category = path.relative(env.source, path.dirname(env.fullpath));
  env.title = path.basename(env.fullpath, path.extname(env.fullpath));
  permalink_style = settings.permalink ? 
    (permalink_styles[settings.permalink] || settings.permalink) : 
    permalink_styles.date;
  return permalink_style.replace(/:(\w+)/g, function (match, item) {
    return env[item];
  });
}

module.exports = parser;
