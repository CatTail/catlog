var http = require('http')
  , util = require('util')
  , static = require('node-static')
  , server = {};

server.run = function run (options) {
  http.createServer(function (request, response) {
    request.addListener('end', function () {
      new static.Server(options.root).serve(request, response);
    });
  }).listen(options.port);
  console.log(util.format(
    'listen on %s with port %s', options.root, options.port));
};

module.exports = server;
