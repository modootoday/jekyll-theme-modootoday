# frozen_string_literal: true
# The header nav resolver (site/nav.html): _data/nav, then _data/navigation.yml main, then header_pages, then
# titled pages (nav_order first, then by title), and modootoday.nav: false turns the last one off.
require "minitest/autorun"
require_relative "../support/native_site"

class NavResolverTest < Minitest::Test
  include NativeSite

  PAGES = {
    "zebra.md" => ["title: Zebra\n"],
    "apple.md" => ["title: Apple\n"],
    "first.md" => ["title: First\nnav_order: 1\n"],
    "hidden.md" => ["title: Hidden\nnav: false\n"],
    "jtd.md" => ["title: Excluded\nnav_exclude: true\n"],
    "team.md" => ["title: Team\nlayout: team\nitems: [{name: Ann}]\n"],
  }.freeze

  def nav(site, page = "index.html") = File.read("#{site}/#{page}")[%r{<nav class="mt-nav".*?</nav>}m].to_s
  def links(site) = nav(site).scan(%r{<li><a href="([^"]+)"}).flatten.uniq

  def test_titled_pages_without_nav_data
    Dir.mktmpdir do |d|
      _src, site = build_minima(d, PAGES)
      assert_equal %w[/first/ /about/ /apple/ /team/ /zebra/], links(site)
      refute_includes nav(site), "mt-nav-group", "a page's own items: is not a nav group"
      refute_includes File.read("#{site}/about/index.html"), "mt-pagination", "no pager over the automatic list"
    end
  end

  def test_header_pages_then_navigation_yml_then_nav_data
    Dir.mktmpdir do |d|
      _src, site = build_minima(d, PAGES, config: "header_pages: [zebra.md, about.markdown]\n")
      assert_equal %w[/zebra/ /about/], links(site)
    end
    Dir.mktmpdir do |d|
      main = { "_data/navigation.yml" => "main:\n  - {title: Apple, url: /apple/}\n" }
      _src, site = build_minima(d, PAGES, config: "header_pages: [zebra.md]\n", files: main)
      assert_equal %w[/apple/], links(site), "_data/navigation.yml main wins over header_pages"
    end
  end

  def test_nav_false_turns_the_titled_list_off
    Dir.mktmpdir do |d|
      _src, site = build_minima(d, PAGES, config: "modootoday: {nav: false}\n")
      assert_empty nav(site)
    end
  end
end
