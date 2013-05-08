var fs = require('fs');
var path = require('path');
var marked = require('marked');
var settings = require('./settings');
var ejs = require('ejs');
var ncp = require('ncp').ncp;
var static = require('node-static');
var _ = require('underscore');
var pygments = require('pygments');
var async = require('async');

marked.setOptions({
  gfm: true,
  tables: true,
  breaks: false,
  pedantic: false,
  sanitize: true,
  smartLists: true,
  langPrefix: 'highlight lang-',
  /*
  highlight: function(code, lang) {
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

function render_post (filename, template) {
  var env = {}, post, options, tokens;
  // permalink
  env.permalink = parse_permalink(filename, env);
  // post
  post = fs.readFileSync(filename, 'utf8');
  // hack for pygment syntax async highlight
  tokens = marked.lexer(parse_post(post, env));
  async.forEach(tokens, function (token, callback) {
    if (token.type === 'code') {
      pygments.colorize(token.text, token.lang, 'html', function (data) {
        token.escaped = true;
        token.text = data;
        callback();
      }, {'P': 'nowrap=true'});
    } else {
      callback();
    }
  }, function () {
    post = marked.parser(tokens);
    (options = _.clone(settings)).section = post;
    post = ejs.render(template, options);
    mkdir_parent(path.dirname(settings.destination+env.permalink));
    fs.writeFileSync(settings.destination+env.permalink, post, 'utf8');
  });
  return env;
}

function updater (filename, template) {
  render_post(filename, template);
}

(function(){
  var theme_dir = './themes/' + settings.theme;
  var template = fs.readFileSync(theme_dir + '/template.html', 'utf8');
  var list_template = fs.readFileSync(theme_dir + '/list.html', 'utf8');
  var envs = [];
  ncp(theme_dir, settings.destination, function (err) {
    var options;
    traverse(settings.source, function (dir) {
      var newDir;
      if (dir !== settings.source) {
        if (fs.statSync(dir).isDirectory()) {
          newDir = dir.replace(settings.source, settings.destination);
          !fs.existsSync(newDir) && fs.mkdirSync(newDir);
        } else {
          if (path.extname(dir) === '.md') {
            envs.push(render_post(dir, template));
            fs.watchFile(dir, {persistent: true, interval: 1000}, function () {
              updater(dir, template);
            });
          }
        }
      }
    });
    (options = _.clone(settings)).section = ejs.render(list_template, {articles: envs});
    fs.writeFileSync(settings.destination+'/index.html', ejs.render(template, options), 'utf8');
  });

  var fileServer = new static.Server(settings.destination);
  require('http').createServer(function (request, response) {
    request.addListener('end', function () {
      fileServer.serve(request, response);
    });
  }).listen(settings.port);
  console.log('Server destination with http://localhost:'+settings.port);
}());
