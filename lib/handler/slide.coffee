fs = require 'fs-extra'
path = require 'path'
marked = require 'marked'
_ = require 'underscore'
directory = require '../directory'
engine = {
  ejs: require 'ejs'
  jade: require 'jade'
}
handler = {}

marked.setOptions {
  gfm: true
  tables: true
  breaks: false
  pedantic: false
  sanitize: false
  smartLists: true
  langPrefix: ''
}

handler.parse = (post, callback) ->
  content = fs.readFileSync post.src, 'utf8'
  md_slides = content.split('\n---\n')
  slides = []
  # Process each slide separately.
  for md_slide in md_slides
    slide = {}
    sections = md_slide.split('\n\n')
    # Extract metadata at the beginning of the slide (look for key: value)
    # pairs.
    metadata_section = sections[0]
    metadata = @parse_metadata(metadata_section)
    _.defaults slide, metadata
    remainder_index = metadata and 1 or 0
    # Get the content from the rest of the slide.
    content_section = sections.slice(remainder_index).join('\n\n')
    html = marked(content_section)
    slide.content = @postprocess_html(html, metadata)

    slides.push(slide)
  post.slides = slides
  callback()

handler.parse_metadata = (section) ->
  #Given the first part of a slide, returns metadata associated with it.
  metadata = {}
  metadata_lines = section.split('\n')
  for line in metadata_lines
    colon_index = line.indexOf(':')
    if colon_index != -1
      key = line.slice(0, colon_index).trim()
      val = line.slice(colon_index+1).trim()
      metadata[key] = val
  return metadata

handler.postprocess_html = (html, metadata) ->
  #Returns processed HTML to fit into the slide template format.
  if metadata.build_lists and metadata.build_lists is 'true'
    html = html.replace('<ul>', '<ul class="build">')
    html = html.replace('<ol>', '<ol class="build">')
  return html

handler.render = (post, callback) ->
  # markdown interpolation
  if post.content
    post.content = engine.ejs.render post.content, post
  # render
  src = path.join post.theme_path, post.theme, 'post'
  dest = path.join post.destination, post.permalink
  # post
  dir = path.dirname src
  type = path.basename src
  # use index.html if permalink don't have filename
  dest = path.join(dest, if path.extname dest then '' else 'index.html')
  for file in fs.readdirSync dir
    if file.indexOf(type) is 0
      format = path.extname(file).slice(1)
      filename = "#{src}.#{format}"
      raw = fs.readFileSync filename, 'utf8'
      html = engine[format].render raw, _.defaults({filename: filename}, post)
  if not fs.existsSync path.dirname dest
    directory.mkdir_parent path.dirname(dest), null
  fs.writeFileSync dest, html, 'utf8'
  # assets
  # use current directory if permalink don't have filename
  assets = path.join path.dirname(post.src), 'assets'
  fs.copy "#{assets}", "#{path.dirname dest}/assets"

module.exports = handler
