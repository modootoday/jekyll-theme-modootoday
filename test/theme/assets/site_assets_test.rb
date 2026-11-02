# frozen_string_literal: true
# The site's own sheets and preload hints (modootoday.site_css, modootoday.preload and the same front matter keys):
# where the tags go, which values are skipped, and that a site without them gets no new tags.
require "minitest/autorun"
require_relative "../../layouts/site"

class SiteAssetsTest < Minitest::Test
  include LayoutSite

  CONFIG = "modootoday:\n  site_css: [/assets/css/site.css, https://cdn.example.org/x.css, //cdn.example.org/y.css]\n" \
           "  preload:\n    - {href: /assets/fonts/a.woff2, as: font, type: font/woff2}\n" \
           "    - {href: /assets/img/hero.webp, as: image}\n    - {href: /assets/x.bin, as: audio}\n"
  PAGES = {
    "p/one.md" => ["title: One\nsite_css: [/assets/css/one.css, /assets/css/site.css]\npreload: [{href: /assets/fonts/b.woff2, as: font}]\n"],
    "p/bad.md" => ["title: Bad\nsite_css: /assets/css/one.css\npreload: {href: /assets/fonts/b.woff2, as: font}\n"],
    "p/plain.md" => ["title: Plain\n"]
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

  def test_site_sheets_follow_the_theme_sheets_once_each
    h = head("p/one.md")
    links = h.scan(/<link rel="stylesheet" href="([^"]+)"/).flatten
    site = links.grep(%r{/assets/css/(site|one)\.css})
    assert_equal %w[/assets/css/site.css /assets/css/one.css], site.map { |u| u.sub(/\?v=.*/, "") }
    site.each { |u| assert_match(/\?v=/, u, "site sheets take the theme's ?v= query") }
    assert_operator links.index(site.first), :>, links.rindex { |u| u.include?("/assets/css/modootoday") }
    refute_includes h, "cdn.example.org", "only site paths are linked"
  end

  def test_preload_hints_come_before_the_stylesheets
    h = head("p/one.md")
    tags = h.scan(/<link rel="preload"[^>]*>/)
    assert_equal ['<link rel="preload" href="/assets/fonts/a.woff2" as="font" type="font/woff2" crossorigin>',
                  '<link rel="preload" href="/assets/img/hero.webp" as="image">',
                  '<link rel="preload" href="/assets/fonts/b.woff2" as="font" crossorigin>'], tags
    assert_operator h.index("rel=\"preload\""), :<, h.index("rel=\"stylesheet\"")
  end

  def test_front_matter_of_the_wrong_shape_is_ignored
    h = head("p/bad.md")
    refute_includes h, "one.css"
    refute_includes h, "b.woff2"
    assert_includes h, "/assets/css/site.css"
  end

  def test_a_site_without_the_keys_gets_no_tags
    Dir.mktmpdir do |d|
      h = html(build_site(d, PAGES.slice("p/plain.md"))[1], "p/plain.md")
      refute_includes h, "rel=\"preload\""
      refute_match(%r{href="/assets/css/(?!modootoday)}, h)
    end
  end
end
