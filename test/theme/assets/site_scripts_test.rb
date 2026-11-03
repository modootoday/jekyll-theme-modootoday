# frozen_string_literal: true
# The site's module scripts (modootoday.scripts) named by script: on hero: or a section item, and poster: images:
# the head tags, the visual markup, the visual sheet, and that pages without them get none of it. The site has a baseurl.
require "minitest/autorun"
require_relative "../../layouts/site"

class SiteScriptsTest < Minitest::Test
  include LayoutSite

  CONFIG = "baseurl: /b\nmodootoday:\n  scripts:\n" \
           "    orbit: {src: /assets/js/orbit.js, css: /assets/css/orbit.css, preload: [/assets/js/scene.js, https://cdn.example.org/a.js]}\n" \
           "    remote: {src: https://cdn.example.org/x.js}\n"
  HERO = "hero: {c: split, script: orbit, poster: {path: /assets/p.webp, srcset: \"/assets/p-640.webp 640w, https://cdn.example.org/p.webp 1280w\", width: 640, height: 480}}\n"
  PAGES = {
    "v/hero.md" => ["title: H\n#{HERO}sections: [{name: a, script: orbit, poster: /assets/q.webp}, {name: b, script: missing}]\n",
                    "# H\n\nLead.\n\n## A\n\nText.\n\n## B\n\nText.\n"],
    "v/remote.md" => ["title: R\nhero: {script: remote}\nsections: [a]\n", "# R\n\nLead.\n\n## A\n\nText.\n"],
    "v/plain.md" => ["title: P\nhero: {c: split, visual: showcase}\nsections: [a]\n", "# P\n\nLead.\n\n## A\n\nText.\n"]
  }.freeze

  # One build shared by the tests below.
  def built
    self.class.instance_variable_get(:@built) || self.class.instance_variable_set(:@built, begin
      d = Dir.mktmpdir
      Minitest.after_run { FileUtils.rm_rf(d) }
      build_site(d, PAGES, config: CONFIG)[1]
    end)
  end

  def head(name) = html(built, name)[%r{<head>.*</head>}m]
  def main(name) = html(built, name)[%r{<main.*</main>}m]

  def test_head_links_the_named_module_once_with_its_sheet_and_preloads
    h = head("v/hero.md")
    assert_equal 1, h.scan(%r{<script type="module" src="/b/assets/js/orbit\.js\?v=[^"]+"></script>}).size
    assert_match %r{<link rel="stylesheet" href="/b/assets/css/orbit\.css\?v=[^"]+">}, h
    assert_equal ['<link rel="modulepreload" href="/b/assets/js/scene.js">'], h.scan(/<link rel="modulepreload"[^>]*>/)
    assert_operator h.index("orbit.css"), :<, h.index("type=\"module\"")
    refute_includes h, "missing"
    refute_includes h, "cdn.example.org"
  end

  def test_split_hero_poster_comes_first_and_is_fetched_first
    m = main("v/hero.md")
    vis = m[%r{<div class="mt-section-visual" data-mt-script="orbit">.*?</div>}m]
    assert vis, m
    assert_includes vis, '<img class="mt-visual-poster" src="/b/assets/p.webp" srcset="/b/assets/p-640.webp 640w, https://cdn.example.org/p.webp 1280w" ' \
                         'sizes="(min-width: 48rem) 50vw, 100vw" width="640" height="480" alt="" fetchpriority="high" decoding="async">'
  end

  def test_section_poster_is_wrapped_and_lazy
    m = main("v/hero.md")
    assert_includes m, '<div class="mt-visual" data-mt-script="orbit"><img class="mt-visual-poster" src="/b/assets/q.webp" alt="" loading="lazy" decoding="async"></div>'
    assert_includes m, '<div class="mt-visual" data-mt-script="missing"></div>'
  end

  def test_visual_sheet_only_where_used
    assert_match %r{/b/assets/css/modootoday/visual\.css}, head("v/hero.md")
    assert_match %r{/b/assets/css/modootoday/visual\.css}, head("v/remote.md"), "a script without a poster still gets the sheet"
    refute_includes head("v/plain.md"), "visual.css"
    css = File.read("#{built}/assets/css/modootoday/visual.css")
    assert_match(/\[data-mt-ready\]\s*>\s*\.mt-visual-poster\s*\{\s*opacity:\s*0/, css)
  end

  def test_remote_src_and_pages_without_script_get_no_module
    refute_includes head("v/remote.md"), "type=\"module\""
    h = html(built, "v/plain.md")
    refute_includes h, "type=\"module\""
    refute_includes h, "data-mt-script"
    refute_includes h, "mt-visual-poster"
  end
end
