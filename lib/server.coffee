http = require 'http'
util = require 'util'
nodestatic = require 'node-static'
open = require 'open'
server = {}

server.run = (options) ->
  http.createServer((request, response) ->
    request.addListener('end', (->
      new nodestatic.Server(options.path).serve(request, response)
    )).resume()
  ).listen(options.port)

  open "http://localhost:#{options.port}"
  console.log "listen on #{options.path} with port #{options.port}"

module.exports = server
