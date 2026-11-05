# frozen_string_literal: true
# Widgets: a c: widget section and a widget: code span place the site's custom element around a light-DOM fallback, link
# the widget sheet and the entry's module only where the element is, and keep :defined through the active Sass.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class WidgetTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  CONFIG = "modootoday:\n  scripts:\n    counter: {src: /assets/js/x-counter.js, css: /assets/css/x-counter.css, element: x-counter}\n" \
           "    orbit: {src: /assets/js/orbit.js}\n"
  SECTION = "---\ntitle: Section\nsections: [{c: widget, name: w, widget: x-counter, props: {start: 2, label: \"Count <it>\"}}, plain]\n---\n" \
            "# Section\n\n## Counter\n\nThe count starts at 2.\n\n| Step | Count |\n|---|---|\n| 1 | 3 |\n\n## Plain\n\nText.\n"
  INLINE = "---\ntitle: Inline\nwidget_props: {x-counter: {start: 5}}\n---\n# Inline\n\n`widget:x-counter`\n\nAfter.\n\n`widget:x-missing`\n\n" \
           "Mentions `widget:x-counter` in prose.\n"

  def self.build
    dir = Dir.mktmpdir
    src = File.join(dir, "src")
    FileUtils.mkdir_p(src)
    FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
    File.write(File.join(src, "_config.yml"), "title: S\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\n" \
               "defaults: [{scope: {path: ''}, values: {layout: doc}}]\n#{CONFIG}")
    File.write(File.join(src, "section.md"), SECTION)
    File.write(File.join(src, "inline.md"), INLINE)
    File.write(File.join(src, "plain.md"), "---\ntitle: Plain\n---\n# Plain\n\nNo widget here.\n")
    cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
    Jekyll.logger.log_level = :error
    Dir.chdir(src) { Jekyll::Site.new(cfg).process }
    at_exit { FileUtils.rm_rf(dir) }
    out = %w[section inline plain].to_h { |n| [n, File.read(File.join(dir, "_site", n, "index.html"))] }
    out.merge("css" => File.read(File.join(dir, "_site/assets/css/modootoday/media/widget.css")))
  end

  def site = (@@site ||= self.class.build)
  def main(n) = site[n][%r{<main.*</main>}m]
  def head(n) = site[n][%r{<head>.*</head>}m]

  def test_section_wraps_the_text_after_its_heading_in_the_element
    sec = main("section")[/<section[^>]*data-section="w".*?<\/section>/m]
    assert_match(/<section class="mt-section mt-c-widget" data-section="w" data-c="widget">/, sec)
    props = "{&quot;start&quot;:2,&quot;label&quot;:&quot;Count &lt;it&gt;&quot;}"
    assert_match(%r{</h2>\s*<x-counter class="mt-widget" data-props="#{props}"><div class="mt-widget-fallback">\s*<p>The count starts at 2.</p>.*</table></div>\s*</div>\s*</x-counter>}m, sec)
  end

  def test_inline_span_takes_front_matter_props_and_the_fallback_sentence
    m = main("inline")
    assert_includes m, '<x-counter class="mt-widget" data-props="{&quot;start&quot;:5}"><div class="mt-widget-fallback">' \
                       "<p>This interactive content needs JavaScript.</p></div></x-counter>"
    assert_match(%r{<p><code[^>]*>widget:x-missing</code></p>}, m)
    assert_match(%r{Mentions <code[^>]*>widget:x-counter</code> in prose}, m)
  end

  def test_module_and_sheets_only_where_the_element_is
    %w[section inline].each do |n|
      h = head(n)
      assert_equal 1, h.scan(%r{<script type="module" src="/assets/js/x-counter\.js\?v=[^"]+"></script>}).size, n
      assert_match %r{<link rel="stylesheet" href="/assets/css/x-counter\.css\?v=[^"]+">}, h
      assert_match %r{href="/assets/css/modootoday/media/widget\.css\?v=[^"]+"}, h
      refute_includes h, "orbit.js"
    end
    refute_includes site["plain"], "x-counter"
    refute_includes site["plain"], "widget.css"
  end

  def test_fallback_rules_survive_the_active_sass
    css = site["css"]
    assert_match(/\.mt-widget:defined\s*>\s*\.mt-widget-fallback\s*\{\s*display:\s*none/, css)
    assert_match(/\.mt-widget\s*\{\s*display:\s*block/, css)
  end
end
