#! /usr/bin/env node

var commander = require('commander');
var settings = require('../settings');
var ejs = require('ejs');
var fs = require('fs');
var moment = require('moment');
var path = require('path');

var categories = fs.readdirSync(settings.source);
console.log(categories);

commander.prompt('title: ', function (title) {
  commander.choose('category:', categories, function (index, category) {
    commander.prompt('author(blank to use default settings): ', function (author) {
      author = author || settings.author;
      var date = moment().format('YYYY-MM-DD');
      var time = moment().format('HH:mm:ss');
      // render
      var header = fs.readFileSync('./assets/header.ejs', 'utf8');
      header = ejs.render(header, {
        title: title, category: category, date: date, time: time, author: author
      });
      // create
      var basename = path.join(settings.source, category, title);
      fs.mkdirSync(basename);
      fs.writeFileSync(path.join(basename, title+'.md'), header, 'utf8');
      process.stdin.destroy();
    });
  });
});
