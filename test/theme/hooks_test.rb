# frozen_string_literal: true
# Additive 1.0 hooks from consumer feedback: section/hero visual includes, page.full_width,
# modootoday.hreflang independent of seo, and their checker rules.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"
require "jekyll"

class ConsumerHooksTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  CHECK = File.join(ROOT, "exe/modootoday-check")
  CLEAN_ENV = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze
  PAGE = <<~MD
    ---
    title: Land
    full_width: true
    hero: {visual: player}
    sections: [{name: one, visual: player, scene: dark}, two]
    ---
    # Land

    ## One

    Text.

    ## Two

    More.
  MD

  def self.site(extra)
    (@s ||= {})[extra] ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(File.join(src, "_includes/sections"))
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_includes/sections/player.html"), '<div class="v">{{ include.section.scene | default: "hero" }}</div>')
      File.write(File.join(src, "_config.yml"), "title: Site\nurl: https://example.org\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\n" \
                                                "defaults: [{scope: {path: ''}, values: {layout: doc}}]\n#{extra}")
      File.write(File.join(src, "index.md"), PAGE)
      FileUtils.mkdir_p(File.join(src, "ko"))
      File.write(File.join(src, "ko/index.md"), "---\ntitle: K\nlang: ko\n---\n# K\n")
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      [src, File.read(File.join(dir, "_site/index.html"))]
    end
  end

  def test_visual_includes_and_full_width
    _, h = self.class.site("")
    assert_match(%r{<section class="mt-hero">.*<div class="v">hero</div></section>}m, h)
    assert_match(%r{data-section="one">\s*<h2 .*<div class="v">dark</div></section>}m, h)
    assert_equal 2, h.scan('<div class="v">').size
    assert_includes h, 'class="mt-main mt-main-full"'
  end

  def test_hreflang_follows_seo_by_default_and_can_be_kept
    _, on = self.class.site("modootoday: {languages: [en, ko]}\n")
    assert_includes on, 'hreflang="ko"'
    _, off = self.class.site("modootoday: {languages: [en, ko], seo: false}\n")
    refute_includes off, "hreflang"
    refute_includes off, 'rel="canonical"'
    _, kept = self.class.site("modootoday: {languages: [en, ko], seo: false, hreflang: true}\n")
    assert_includes kept, '<link rel="alternate" hreflang="ko" href="https://example.org/ko/">'
    refute_includes kept, 'rel="canonical"'
    refute_includes kept, "og:title"
  end

  def run_check(src)
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, src, File.join(src, "_nosite"))
    [o + e, st.exitstatus]
  end

  def test_checker_visual_rules
    Dir.mktmpdir do |d|
      FileUtils.mkdir_p("#{d}/_includes/sections")
      File.write("#{d}/_includes/sections/player.html", "x")
      File.write("#{d}/_config.yml", "modootoday: {hreflang: maybe}\n")
      File.write("#{d}/ok.md", PAGE)
      File.write("#{d}/bad.md", PAGE.sub("hero: {visual: player}", "hero: {visual: missing}").sub("visual: player,", "visual: Bad/x,"))
      o, code = run_check(d)
      assert_equal 1, code, o
      refute_match(/ok\.md/, o)
      assert_includes o, "bad.md: hero.visual: _includes/sections/missing.html not found"
      assert_includes o, "bad.md: sections[0].visual must be an include name"
      assert_includes o, "modootoday.hreflang must be true or false"
    end
  end

  def test_checker_allows_tool_region_markers_only
    Dir.mktmpdir do |d|
      File.write("#{d}/ok.md", "---\ntitle: A\n---\n# A\n\n<!-- spec:toc:begin -->\n- x\n<!-- spec:toc:end -->\n")
      File.write("#{d}/bad.md", "---\ntitle: B\n---\n# B\n\n<!-- note: begin -->\n")
      o, code = run_check(d)
      assert_equal 1, code, o
      refute_match(/ok\.md/, o)
      assert_includes o, "bad.md: HTML comment"
    end
  end

  def test_breadcrumb_home_short_title
    Dir.mktmpdir do |d|
      src = File.join(d, "src")
      FileUtils.mkdir_p("#{src}/guide")
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |x| File.join(ROOT, x) }, src)
      File.write("#{src}/_config.yml", "title: Site\nurl: https://example.org\npermalink: pretty\ndefaults: [{scope: {path: ''}, values: {layout: doc}}]\n")
      File.write("#{src}/index.md", "---\ntitle: A very long home page title\nshort_title: Home\n---\n# H\n")
      File.write("#{src}/guide/index.md", "---\ntitle: Guide\n---\n# Guide\n")
      cfg = Jekyll.configuration("source" => src, "destination" => "#{d}/_site", "quiet" => true)
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      h = File.read("#{d}/_site/guide/index.html")
      assert_match(%r{mt-breadcrumb.*<a href="/">Home</a>}m, h)
    end
  end
end
