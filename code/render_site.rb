require 'rubygems'
require 'haml'
require 'sass'
require 'fileutils'


# http://stackoverflow.com/questions/6125265/using-layouts-in-haml-files-independently-of-rails
def render(page, stylesheets, locals={})
  rendered_html = Haml::Engine.new(File.read('haml/base/layout.html.haml')).render(Object.new, stylesheets) do
    Haml::Engine.new(File.read("haml/pages/#{page}.html.haml")).render(Object.new, locals)
  end

  File.open("../resolution-compare/#{page}.html", 'w+') do |f|
    f.write(rendered_html)
  end
end

def render_partial(partial, locals={})
  Haml::Engine.new(File.read("haml/partials/_#{partial}.html.haml")).render(Object.new, locals)
end

def render_to_css(sheet)
  rendered_css = Sass::Engine.new(
    File.read("./stylesheets/#{sheet}.css.scss"),
    syntax: :scss
  ).render

  File.open("../resolution-compare/assets/#{sheet}.css", 'w+') do |f|
    f.write(rendered_css)
  end
end

JS_REQUIREMENTS_ORDERED = [
  'jquery.min.js',
  'https://widget.cloudinary.com/global/all.js',
  'main.js'
]

def render_js
  output_dir = '../resolution-compare/assets/javascript'
  input_dir = './javascript'
  `coffee -o #{output_dir}/ -c #{input_dir}/`

  Dir.glob(File.join(input_dir, '*.js')).each do |f|
    FileUtils.cp(f, File.join(output_dir, File.basename(f)))
  end

  JS_REQUIREMENTS_ORDERED.map { |js| js.include?('http') ? js : File.join(output_dir, js)}
end

def clear_files
  output_files = Dir.glob("../resolution-compare/**/*.{html,css,js}")
  output_files.each { |f| File.delete(f) }
end

def render_all
  clear_files

  js_files = render_js

  stylesheet_extension = '.css.scss'
  stylesheets = Dir.glob("./stylesheets/*#{stylesheet_extension}").map { |ss| File.basename(ss, stylesheet_extension) }
  stylesheets.each { |ss| render_to_css(ss) }

  page_extension = '.html.haml'
  pages = Dir.glob("./haml/pages/*#{page_extension}").map { |p| File.basename(p, page_extension) }
  pages.each { |p| render(p, {stylesheets: stylesheets}, {scripts: js_files}) }
end

def size_transform(size_string)
  width, height = size_string.split('x')
  "w_#{width},h_#{height},c_fit"
end


render_all

