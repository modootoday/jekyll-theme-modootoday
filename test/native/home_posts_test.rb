# frozen_string_literal: true
# The home layout's post list (blog/home-list.html): on by itself only without hero and sections:, posts: true or
# false wins, list_title names it, show_excerpts (page, then site) decides the excerpts. And layout: page is doc.
require "minitest/autorun"
require_relative "../support/native_site"

class HomePostsTest < Minitest::Test
  include NativeSite

  LIST = 'class="mt-blog mt-home-posts"'
  HERO = "hero: {title: Hello}\n"

  def test_list_follows_hero_sections_and_posts
    Dir.mktmpdir do |d|
      _src, site = build_minima(d, {
        "hero.md" => ["layout: home\npermalink: /hero/\n#{HERO}"],
        "sections.md" => ["layout: home\npermalink: /sections/\nsections: [a]\n", "Lead.\n\n## A\n\nText.\n"],
        "forced.md" => ["layout: home\npermalink: /forced/\nposts: true\nlist_title: Writing\nshow_excerpts: false\n#{HERO}"],
        "off.md" => ["layout: home\npermalink: /off/\nposts: false\n"],
      }, config: "show_excerpts: true\n")
      home = File.read("#{site}/index.html")
      assert_includes home, LIST
      assert_includes home, '<h2 id="mt-home-posts-title">Latest</h2>'
      assert_includes home, 'class="mt-card-post-excerpt"', "site show_excerpts: true"
      assert_includes home, "/assets/css/modootoday-blog.css", "the list's cards get the blog sheet"
      hero = File.read("#{site}/hero/index.html")
      refute_includes hero, LIST
      refute_includes hero, "/assets/css/modootoday-blog.css"
      refute_includes File.read("#{site}/sections/index.html"), LIST
      refute_includes File.read("#{site}/off/index.html"), LIST
      forced = File.read("#{site}/forced/index.html")
      assert_includes forced, '<h2 id="mt-home-posts-title">Writing</h2>'
      refute_includes forced, 'class="mt-card-post-excerpt"', "page show_excerpts: false wins"
    end
  end

  def test_page_is_the_doc_layout
    assert_match(/\A---\nlayout: doc\n---\n/, File.read(File.join(ROOT, "_layouts/page.html")))
  end
end
