# frozen_string_literal: true
# Icon include (_includes/modootoday/brand/icon.html), the logo/favicon options and their accessibility.
require "minitest/autorun"
require "tmpdir"
require "open3"
require "fileutils"

class IconTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  EXAMPLE = File.join(ROOT, "example")
  ICON = File.read(File.join(ROOT, "_includes/modootoday/brand/icon.html"))
  DEFINED = ICON.scan(/\{%-? when (.+?) -?%\}/).flatten.flat_map { |w| w.scan(/"([a-z-]+)"/).flatten }

  def build(dir, overlay)
    File.write("#{dir}/o.yml", overlay)
    out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", EXAMPLE, "-d", "#{dir}/s",
                              "--config", "#{EXAMPLE}/_config.yml,#{dir}/o.yml", chdir: ROOT)
    assert st.success?, out
    "#{dir}/s"
  end

  def test_every_icon_name_used_in_the_theme_and_docs_is_defined
    used = Dir[File.join(ROOT, "{_layouts,_includes,docs,example}/**/*.{html,md}")].flat_map do |f|
      File.read(f).scan(/icon\.html name="([a-z-]+)"/).flatten
    end.uniq
    refute_empty used
    assert_empty used - DEFINED, "undefined icon names"
    %w[note tip important warning caution].each { |t| assert_includes DEFINED, t, "callout type #{t}" }
    js = File.read(File.join(ROOT, "assets/js/modootoday/code-copy.js"))
    assert_match(/<svg[^"]*class="mt-icon/, js)
  end

  def test_icons_are_decorative_or_labelled_and_icon_buttons_have_names
    Dir.mktmpdir do |d|
      html = File.read("#{build(d, "modootoday: {logo: brand}\n")}/guide/index.html")
      svgs = html.scan(/<svg class="mt-icon[^>]*>/)
      refute_empty svgs
      svgs.each do |s|
        assert_includes s, 'focusable="false"'
        assert(s.include?('aria-hidden="true"') || s =~ /role="img" aria-label="[^"]+"/, s)
        assert_match(/width="\d\d?" height="\d\d?"/, s)
      end
      assert_match(/<button class="mt-theme-toggle"[^>]*aria-label="[^"]+"/, html)
      refute_match(/https?:\/\/[^"]*\.svg/, html, "icons are inline, no external requests")
      assert_match(/class="mt-site-title md-site-title mt-has-logo"[^>]*><svg class="mt-icon mt-icon-brand mt-logo"/, html)
    end
  end

  def test_icon_label_and_unknown_name
    Dir.mktmpdir do |d|
      FileUtils.cp_r("#{EXAMPLE}/.", "#{d}/src")
      File.write("#{d}/src/icons.md", "---\nlayout: null\n---\n{% include modootoday/brand/icon.html name=\"rss\" label=\"Feed\" %}|" \
                                      "{% include modootoday/brand/icon.html name=\"nope\" %}|{% include modootoday/brand/icon.html name=\"next\" size=12 %}")
      out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", "#{d}/src", "-d", "#{d}/s", chdir: ROOT)
      assert st.success?, out
      a, b, c = File.read("#{d}/s/icons/index.html").split("|")
      assert_match(/role="img" aria-label="Feed"/, a)
      refute_includes a, "aria-hidden"
      assert_equal "", b.strip
      assert_match(/mt-icon-flip.*width="12"/, c)
    end
  end

  def test_logo_path_and_favicon_options
    Dir.mktmpdir do |d|
      html = File.read("#{build(d, "modootoday: {logo: /img/logo.png, favicon: brand}\n")}/guide/index.html")
      assert_match(%r{<img class="mt-logo" src="[^"]*/img/logo.png" alt=""}, html)
      assert_includes html, 'favicon.svg" type="image/svg+xml"'
      assert_includes html, 'rel="apple-touch-icon"'
      assert File.exist?("#{d}/s/assets/modootoday/favicon-32.png")
      plain = File.read("#{build(d, "x: 1\n")}/guide/index.html")
      refute_includes plain, "mt-has-logo"
      refute_includes plain, 'rel="icon"'
      own = File.read("#{build(d, "modootoday: {favicon: /f.ico}\n")}/guide/index.html")
      assert_match(%r{<link rel="icon" href="[^"]*/f.ico">}, own)
    end
  end
end
