var fs = require('fs')
  , path = require('path')
  , util = require('util')
  , marked = require('marked')
  , async = require('async')
  , pygments = require('pygments')
  , ejs = require('ejs')
  , root = path.join(__dirname, '..')
  , render = {};

marked.setOptions({
  gfm: true,
  tables: true,
  breaks: false,
  pedantic: false,
  sanitize: true,
  smartLists: true,
  langPrefix: 'highlight lang-',
  //highlight: function(code, lang) {
    //return code;
  //}
});

render.render_post = function render_post (env, callback) {
  var tokens, template;
  // hack for pygment syntax async highlight
  tokens = marked.lexer(env.post);
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
    // ejs option
    env.filename = path.join(root, util.format('themes/%s/post.ejs', env.theme));
    template = fs.readFileSync(env.filename, 'utf8');
    env.post = marked.parser(tokens);
    env.post = ejs.render(template, env);
    callback && callback(env);
  });
};

render.render_list = function render_list (env) {
  env.filename = path.join(root, util.format('themes/%s/list.ejs', env.theme));
  env.post = ejs.render(fs.readFileSync(env.filename, 'utf8'), env);
  return env;
};

module.exports = render;
