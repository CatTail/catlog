var fs = require('fs');
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

var theme_dir = './themes/' + settings.theme;
var theme = fs.readFileSync(theme_dir + '/index.html', 'utf8');
ncp(theme_dir, settings.destination, function (err) {
  if (err) {
    console.log(err);
  }
  traverse(settings.source, function (dir) {
    var post, newDir, env;
    if (dir !== settings.source) {
      if (fs.statSync(dir).isDirectory()) {
        newDir = dir.replace(settings.source, settings.destination);
        !fs.existsSync(newDir) && fs.mkdirSync(newDir);
      } else {
        env = {};
        post = fs.readFileSync(dir, 'utf8');
        post = marked(parse_post(post, env));
        post = ejs.render(theme, {section: post});
        fs.writeFileSync(dir.replace(settings.source, settings.destination).replace(/md$/, 'html'), post, 'utf8');
      }
    }
  });
});

var permalinks = {
  date: '/:categories/:year/:month/:day/:title.html',
  none: '/:categories/:title.html'
}:
