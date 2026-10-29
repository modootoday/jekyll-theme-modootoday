# Per-partial CSS size (Ruby Sass): bundle exec ruby qa/css/css-sizes.rb — core plus each component alone, compact and compressed.
require "sass"; require "zlib"
comps = Dir["_sass/modootoday/components/_*.scss"].map { |f| File.basename(f, ".scss")[1..] }.sort
def css(src, style) = Sass::Engine.new(src, syntax: :scss, style: style, load_paths: ["_sass"]).render
pre = "$mt-css-layers: #{ARGV[0] || 'true'};\n@import \"modootoday/core\";\n"
%i[compact compressed].each do |st|
  core = css(pre, st); tot = core.bytesize
  rows = [["core", core.bytesize, Zlib::Deflate.deflate(core, 9).bytesize]]
  comps.each { |c| o = css(pre + "@import \"modootoday/components/#{c}\";", st); rows << [c, o.bytesize - core.bytesize, nil]; tot += o.bytesize - core.bytesize }
  all = css(pre + comps.map { |c| "@import \"modootoday/components/#{c}\";" }.join("\n"), st)
  puts "== #{st}: all #{all.bytesize} B gzip #{Zlib.gzip(all, level: 9).bytesize}"
  rows.sort_by { -_2 }.each { |n, b, _| puts "  #{n.ljust(14)} #{b}" }
end
