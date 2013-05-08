var fs = require('fs');
var path = require('path');
var marked = require('marked');
var settings = require('./settings');
var ejs = require('ejs');
var ncp = require('ncp').ncp;

marked.setOptions({
  gfm: true,
  tables: true,
  breaks: false,
  pedantic: false,
  sanitize: true,
  smartLists: true
  /*
  langPrefix: 'language-',
  highlight: function(code, lang) {
    if (lang === 'js') {
      return highlighter.javascript(code);
    }
    return code;
  }
 */
});

var permalink_styles = {
  date: '/:category/:year/:month/:day/:title.html',
  none: '/:category/:title.html'
};

function mkdir_parent (dir, mode) {
  try {
    fs.mkdirSync(dir, mode);
  } catch (error) {
    if (error && error.errno === 34) {
      mkdir_parent(path.dirname(dir), mode);
      mkdir_parent(dir, mode);
    }
  }
}

/**
 * Traverse directory(could be a file), 
 * given every traversed filename in handler.
 *
 * @param {string} dir Traversed directory name.
 * @param {function(string)} handler Self-defined handler.
 */
function traverse (dir, handler) {
  handler(dir);
  if (fs.statSync(dir).isDirectory()) {
    fs.readdirSync(dir).forEach(function (subdir) {
      traverse(dir+'/'+subdir, handler);
    });
  }
}

// parse post header variables
function parse_post (post, env) {
  var match = post.match(/^\s*\/\*\s*([^\0]*?)\*\//);
  if (match) {
    post = post.slice(match[0].length).trim();
    match[1].trim().split(/\s*\n\s*/).forEach(function (option) {
      option = option.split(/\s*:\s*/);
      env[option[0]] = option[1];
    });
  }
  return post;
}

function parse_permalink (filename, env) {
  var permalink_style;
  env.category = (path.dirname(filename) === settings.source) ? 
    '' : path.relative(settings.source, path.dirname(filename));
  filename = path.basename(filename, path.extname(filename)).split('-');
  env.year = filename[0];
  env.month = filename[1];
  env.day = filename[2];
  env.title = filename.slice(3).join('-');
  permalink_style = settings.permalink ? 
    (permalink_styles[settings.permalink] || settings.permalink) : 
    permalink_styles.date;
  return permalink_style.replace(/:(\w+)/g, function (match, item) {
    return env[item];
  });
}

var theme_dir = './themes/' + settings.theme;
var theme = fs.readFileSync(theme_dir + '/template.html', 'utf8');
ncp(theme_dir, settings.destination, function (err) {
  traverse(settings.source, function (dir) {
    var post, newDir, env, file, permalink;
    if (dir !== settings.source) {
      if (fs.statSync(dir).isDirectory()) {
        newDir = dir.replace(settings.source, settings.destination);
        !fs.existsSync(newDir) && fs.mkdirSync(newDir);
      } else {
        file = dir;
        env = {};
        // permalink
        permalink = parse_permalink(file, env);
        // post
        post = fs.readFileSync(file, 'utf8');
        post = marked(parse_post(post, env));
        post = ejs.render(theme, {section: post, base_url: settings.base_url});
        mkdir_parent(path.dirname(settings.destination+permalink));
        fs.writeFileSync(settings.destination+permalink, post, 'utf8');
      }
    }
  });
});
