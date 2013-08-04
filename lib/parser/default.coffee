marked = require 'marked'
parser = {}

marked.setOptions {
  gfm: true
  tables: true
  breaks: false
  pedantic: false
  sanitize: true
  smartLists: true
  langPrefix: ''
}

parser.parse = (content, callback) ->
  content = marked.parser marked.lexer content
  callback and callback {content: content}

module.exports = parser
