var fs = require('fs')
  , util = require('util')
  , marked = require('marked')
  , async = require('async')
  , pygments = require('pygments')
  , ejs = require('ejs')
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
    template = 
      fs.readFileSync(util.format('themes/%s/template.html', env.theme), 'utf8');
    env.post = marked.parser(tokens);
    env.post = ejs.render(template, env);
    callback && callback(env);
  });
};

module.exports = render;
