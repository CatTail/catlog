marked = require 'marked'
_ = require 'underscore'
parser = {}

marked.setOptions {
  gfm: true
  tables: true
  breaks: false
  pedantic: false
  sanitize: false
  smartLists: true
  langPrefix: ''
}

parser.parse = (content, callback) ->
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
  callback and callback {slides: slides}

parser.parse_metadata = (section) ->
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

parser.postprocess_html = (html, metadata) ->
  #Returns processed HTML to fit into the slide template format.
  if metadata.build_lists and metadata.build_lists is 'true'
    html = html.replace('<ul>', '<ul class="build">')
    html = html.replace('<ol>', '<ol class="build">')
  return html

module.exports = parser
