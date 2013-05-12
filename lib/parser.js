var fs = require('fs')
  , path = require('path')
  , parser = {};

parser.parse_categories = function parse_categories (envs) {
  var categories = [];
  envs.forEach(function (env) {
    if (categories.indexOf(env.category) === -1) {
      categories.push(env.category);
    }
    env.categories = categories;
  });
  return categories;
};

parser.parse_post = function parse_post (env) {
  var post, match;
  post = fs.readFileSync(env.src, 'utf8');
  // parse variables
  match = post.match(/^\s*\/\*\s*([^\0]*?)\*\//);
  if (match) {
    post = post.slice(match[0].length).trim();
    match[1].trim().split(/\s*\n\s*/).forEach(function (option) {
      option = option.split(/\s*:\s*/);
      env[option[0].toLowerCase()] = option[1];
    });
  }
  this.parse_date(env);
  this.parse_permalink(env);
  env.dest = path.join(env.destination, env.permalink);
  return env.post = post;
};
  

var permalink_styles = {
  date: ':category/:year/:month/:day/:title.html',
  none: ':category/:title.html'
};

parser.parse_permalink = function parse_permalink (env) {
  // date is the default permalink style
  env.permalink = permalink_styles[env.permalink_style] && 
    env.permalink_style && permalink_styles.date;
  return env.permalink = env.permalink.replace(/:(\w+)/g, 
                                               function (match, item) {
                                                 return env[item.toLowerCase()];
                                               });
};

parser.parse_date = function parse_date (env) {
  env.date = env.date.split('-');
  env.year = env.date[0];
  env.month = env.date[1];
  env.day = env.date[2];
}

module.exports = parser;
