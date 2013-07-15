fs = require 'fs'
path = require 'path'
_ = require 'underscore'
parser = require '../lib/parser'

canonHtml = (html) -> html.replace(/( |\r|\r\n|\n)/g, '')

describe 'parser', ->
  assets = 'test/assets/parser'

  #describe 'parse_markdown', ->
    #markdownAssets = "#{assets}/markdown"

    #it 'should pass markdown test', ->
      #files = fs.readdirSync markdownAssets
      #files = _.uniq _.map(files, (file) -> file.split('.')[0])
      #for file in files
        #md = fs.readFileSync "#{markdownAssets}/#{file}.text", 'utf8'
        #html = fs.readFileSync "#{markdownAssets}/#{file}.html", 'utf8'
        #
        #
        #parser.parse_markdown md, (content) ->
          #expect(canonHtml html).toEqual(canonHtml content)
