# frozen_string_literal: true
# The author resolver (site/author.html), one owner for the byline, the Atom feed and JSON-LD: a _data/authors.yml key,
# an unknown name, a list, a comma list, a map (jekyll-seo-tag shape, picture as avatar) and site.author as the fallback.
require "minitest/autorun"
require "json"
require_relative "../support/native_site"

class AuthorShapesTest < Minitest::Test
  include NativeSite

  POSTS = {
    "id" => "author: ann\n",
    "map" => "author: {name: Bo Kim, url: \"https://bo.example/\", picture: /bo.png}\n",
    "list" => "authors: [ann, Cy Doe]\n",
    "comma" => "author: \"ann, Dee\"\n",
    "none" => "",
  }.freeze

  def byline(site, slug) = html(site, "p/#{slug}.md")[%r{<p class="mt-byline-authors".*?</p>}m].to_s
  def people(site, slug) = graph(site, "p/#{slug}.md").find { |n| n["author"] }&.fetch("author")

  def test_every_shape_in_byline_feed_and_json_ld
    pages = POSTS.each_with_index.to_h do |(slug, fm), i|
      ["_posts/2026-02-0#{i + 1}-#{slug}.md", ["title: #{slug}\nlayout: post\npermalink: /p/#{slug}/\n#{fm}"]]
    end
    pages["feed.xml"] = ["layout: feed\n", ""]
    files = { "_data/authors.yml" => "ann: {name: Ann Lee, url: /ann/}\n" }
    Dir.mktmpdir do |d|
      _src, site = build_minima(d, pages, config: "author: {name: Jane Doe, email: jane@example.com}\n", files: files)
      assert_includes byline(site, "id"), '<a class="mt-post-author" rel="author" href="/ann/">Ann Lee</a>'
      map = byline(site, "map")
      assert_includes map, '<img class="mt-avatar" src="/bo.png"'
      assert_includes map, '<a class="mt-post-author" rel="author" href="https://bo.example/">Bo Kim</a>'
      assert_match(%r{Ann Lee</a>,\s*<span class="mt-post-author">Cy Doe</span>}, byline(site, "list"))
      assert_match(%r{Ann Lee</a>,\s*<span class="mt-post-author">Dee</span>}, byline(site, "comma"))
      assert_includes byline(site, "none"), '<span class="mt-post-author">Jane Doe</span>'
      assert_equal [{ "@type" => "Person", "name" => "Bo Kim", "url" => "https://bo.example/" }], people(site, "map")
      assert_equal %w[Ann\ Lee Cy\ Doe], people(site, "list").map { |p| p["name"] }
      assert_equal "https://example.org/ann/", people(site, "id").first["url"]
      assert_equal ["Jane Doe"], people(site, "none").map { |p| p["name"] }
      feed = File.read("#{site}/feed.xml")
      %w[Ann\ Lee Bo\ Kim Cy\ Doe Dee Jane\ Doe].each { |n| assert_includes feed, "<author><name>#{n}</name></author>" }
    end
  end
end
