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

traverse(settings.source, function (dir) {
  var post, newDir;
  if (dir !== settings.source) {
    if (fs.statSync(dir).isDirectory()) {
      newDir = dir.replace(settings.source, settings.destination);
      !fs.existsSync(newDir) && fs.mkdirSync(newDir);
    } else {
      post = fs.readFileSync(dir, 'utf8');
      console.log(dir);
      fs.writeFileSync(dir.replace(settings.source, settings.destination).replace(/md$/, 'html'), marked(post), 'utf8');
    }
  }
});
