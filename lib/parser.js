var fs = require('fs')
  , path = require('path')
  , parser = {};

parser.parse_post = function parse_post (env) {
  var post, match;
  this.parse_permalink(env);
  post = fs.readFileSync(env.fullpath, 'utf8');
  // parse variables
  match = post.match(/^\s*\/\*\s*([^\0]*?)\*\//);
  if (match) {
    post = post.slice(match[0].length).trim();
    match[1].trim().split(/\s*\n\s*/).forEach(function (option) {
      option = option.split(/\s*:\s*/);
      env[option[0]] = option[1];
    });
  }
  return env.post = post;
};

var permalink_styles = {
  date: '/:category/:year/:month/:day/:title.html',
  none: '/:category/:title.html'
};

parser.parse_permalink = function parse_permalink (env) {
  // date is the default permalink style
  env.permalink = permalink_styles[env.permalink_style] && 
    env.permalink_style && permalink_styles.date;
  return env.permalink = env.permalink.replace(/:(\w+)/g, 
                                               function (match, item) {
                                                 return env[item];
                                               });
};

module.exports = parser;
