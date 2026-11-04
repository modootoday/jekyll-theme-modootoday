# frozen_string_literal: true
# The page title as the h1 when the body has none (modootoday/pages/title.html) in the doc, page, home and search
# layouts, and the search page's no-JavaScript form: a named landmark, left out without url:.
require "minitest/autorun"
require_relative "../../support/layout_site"

class PageTitleTest < Minitest::Test
  include LayoutSite

  PAGES = {
    "t/about.md" => ["layout: page\ntitle: About & us\n", "This is the base Jekyll theme.\n"],
    "t/own.md" => ["layout: doc\ntitle: Own\n", "# Own heading\n\nText.\n"],
    "t/home.md" => ["layout: home\n", ""],
    "t/search.md" => ["layout: search\ntitle: Search\n", ""],
  }.freeze

  def self.sites = @sites ||= {}

  def site(url)
    self.class.sites[url] ||= begin
      dir = Dir.mktmpdir
      at_exit { FileUtils.rm_rf(dir) }
      build_site(dir, PAGES, url: url).last
    end
  end

  def h1s(h) = h.scan(%r{<h1[^>]*>.*?</h1>}m)

  def test_a_page_without_a_body_h1_gets_its_title
    s = site("https://example.org")
    assert_equal ["<h1>About &amp; us</h1>"], h1s(html(s, "t/about"))
    assert_equal 1, h1s(html(s, "t/own")).size, "a body h1 is not doubled"
    assert_includes h1s(html(s, "t/own")).first, "Own heading"
  end

  def test_home_without_a_hero_title_uses_the_site_title
    s = site("https://example.org")
    title = File.read("#{File.dirname(s)}/src/_config.yml")[/^title:\s*(.+)$/, 1].delete('"')
    assert_equal ["<h1>#{title}</h1>"], h1s(html(s, "t/home"))
  end

  def test_search_page_has_an_h1_and_a_named_form
    h = html(site("https://example.org"), "t/search")
    assert_equal ["<h1>Search</h1>"], h1s(h)
    assert_includes h, '<form class="mt-search-form" role="search" aria-labelledby="mt-search-q-label"'
    assert_includes h, '<label id="mt-search-q-label" for="mt-search-q">'
    assert_includes h, '<input type="hidden" name="sites" value="example.org">'
  end

  def test_search_form_is_left_out_without_url
    h = html(site(""), "t/search")
    refute_includes h, "mt-search-form", "an empty site filter would search the whole web"
    assert_equal ["<h1>Search</h1>"], h1s(h)
  end
end
