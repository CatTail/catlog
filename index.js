var util = require('util')
  , exec = require('child_process').exec
//  , ncp = require('ncp')
  , _ = require('underscore')
  , server = require('./lib/server')
  , generator = require('./lib/generator');

var main = function main () {
  var default_settings = require('./settings')
    , settings = _.defaults({}/* global_settings */, default_settings);
  
  generator.generate(settings);
  // copy themes assets
  // FIXME
  exec(util.format('rm -r ./%s/themes/*', settings.destination), function () {
    exec(util.format('cp -rf ./themes/%s %s;mv %s/%s %s/theme', 
                     settings.theme, settings.destination, settings.destination, 
                     settings.theme, settings.destination));
  });
//  ncp('themes/'+settings.theme, settings.destination, function () {});
  server.run({root: settings.destination, port: settings.port});
};

main();
