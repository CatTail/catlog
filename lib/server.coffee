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

  console.log "start local server".info
  console.log "server running on: http://localhost:#{options.port}".info
  open "http://localhost:#{options.port}"

module.exports = server
