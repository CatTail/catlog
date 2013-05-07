var fs = require('fs');
var marked = require('marked');
var settings = require('./settings');

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

traverse(settings.source, function (dir) {
  var post, newDir, env;
  if (dir !== settings.source) {
    if (fs.statSync(dir).isDirectory()) {
      newDir = dir.replace(settings.source, settings.destination);
      !fs.existsSync(newDir) && fs.mkdirSync(newDir);
    } else {
      post = fs.readFileSync(dir, 'utf8');
      env = {};
      post = parse_post(post, env);
      fs.writeFileSync(dir.replace(settings.source, settings.destination).replace(/md$/, 'html'), marked(post), 'utf8');
    }
  }
});
