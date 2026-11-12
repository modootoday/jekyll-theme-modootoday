# frozen_string_literal: true
# Feed discovery (meta/feed-url.html, meta/feeds.html, blog/subscribe.html): the site feed per language, a page's own
# feed: in the head and as a Subscribe link on blog, author and archive pages, and layout: feed with author:.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class FeedsTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  ATOM = 'rel="alternate" type="application/atom+xml"'

  def self.site
    @site ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(%w[_posts ko authors].map { |d| File.join(src, d) })
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: Site\nlang: en\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\nsass: {silence_deprecations: [import, global-builtin]}\n" \
                                                "modootoday: {feed: true}\n" \
                                                "defaults: [{scope: {path: ''}, values: {layout: doc}}, {scope: {path: ko}, values: {lang: ko}}, {scope: {type: posts}, values: {layout: post}}]\n")
      FileUtils.mkdir_p(File.join(src, "_data"))
      File.write(File.join(src, "_data/authors.yml"), "ana: {name: Ana}\nbo: {name: Bo}\n")
      File.write(File.join(src, "feed.xml"), "---\nlayout: feed\n---\n")
      File.write(File.join(src, "ko/feed.xml"), "---\nlayout: feed\n---\n")
      File.write(File.join(src, "authors/ana.xml"), "---\nlayout: feed\nauthor: ana\n---\n")
      File.write(File.join(src, "blog.md"), "---\ntitle: Blog\nlayout: blog\n---\n# Blog\n")
      File.write(File.join(src, "news.md"), "---\ntitle: News\nlayout: blog\ntag: news\n---\n# News\n")
      File.write(File.join(src, "quiet.md"), "---\ntitle: Quiet\nlayout: blog\nfeed: false\n---\n# Quiet\n")
      File.write(File.join(src, "ko/blog.md"), "---\ntitle: 블로그\nlayout: blog\n---\n# 블로그\n")
      File.write(File.join(src, "authors/ana.md"), "---\ntitle: Ana\nlayout: author\nauthor: ana\nfeed: /authors/ana.xml\n---\n")
      File.write(File.join(src, "authors/bo.md"), "---\ntitle: Bo\nlayout: author\nauthor: bo\nfeed: /authors/missing.xml\n---\n")
      File.write(File.join(src, "tags.md"), "---\ntitle: Tags\nlayout: archive\nfeed: /feed.xml\n---\n# Tags\n")
      File.write(File.join(src, "_posts/2026-10-01-a.md"), "---\ntitle: By Ana\nauthor: ana\ntags: [news]\n---\n# A\n")
      File.write(File.join(src, "_posts/2026-10-02-b.md"), "---\ntitle: By Bo\nauthor: bo\n---\n# B\n")
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      dir
    end
  end

  def read(rel) = File.read(File.join(self.class.site, "_site", rel))

  def subscribe(h) = h[%r{<p class="mt-feed-subscribe">.*?</p>}m]

  def test_a_blog_index_uses_its_language_feed_once
    h = read("blog/index.html")
    assert_equal 1, h.scan(ATOM).size, "the page feed equals the site feed, so it is linked once"
    assert_includes h, %(<link #{ATOM} title="Site" href="/feed.xml">)
    assert_match %r{<a href="/feed\.xml" type="application/atom\+xml"><svg class="mt-icon mt-icon-rss"[^>]*>.*?</svg> Subscribe \(Atom\)</a>}m, subscribe(h)
    k = read("ko/blog/index.html")
    assert_includes k, %(href="/ko/feed.xml")
    assert_includes subscribe(k), "구독 (Atom)"
  end

  def test_a_filtered_blog_or_feed_false_shows_no_subscribe_link
    assert_nil subscribe(read("news/index.html"))
    assert_nil subscribe(read("quiet/index.html"))
  end

  def test_an_author_page_links_its_own_feed_and_drops_a_missing_one
    h = read("authors/ana/index.html")
    assert_includes h, %(<link #{ATOM} title="Site – Ana" href="/authors/ana.xml">)
    assert_includes subscribe(h), 'href="/authors/ana.xml"'
    bo = read("authors/bo/index.html")
    refute_includes bo, "missing.xml"
    assert_nil subscribe(bo)
  end

  def test_an_archive_page_with_feed_shows_the_link
    assert_includes subscribe(read("tags/index.html")), 'href="/feed.xml"'
  end

  def test_layout_feed_takes_author
    x = read("authors/ana.xml")
    assert_includes x, "<title type=\"html\">By Ana</title>"
    refute_includes x, "By Bo"
  end
end
