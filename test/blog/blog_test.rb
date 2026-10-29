# frozen_string_literal: true
# Blog and news layouts (Liquid only): blog index, news front page, post/news-article parts, author page, Atom feed, JSON-LD.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "json"
require "rexml/document"
require "jekyll"

class BlogTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  POSTS = {
    "2026-10-01-a.md" => "title: Alpha\ncategories: [world]\ntags: [x, y]\nauthor: jane\nseries: Intro\nimage: {path: /a.png, alt: A chart, caption: Source A}\n",
    "2026-10-02-b.md" => "title: Beta\ncategories: [world]\ntags: [x]\nseries: Intro\nupdated: 2026-10-03\n",
    "2026-10-04-n.md" => "title: Storm\nlayout: news-article\ncategories: [world]\ntags: [y]\nauthors: [jane, bob]\ndateline: SEOUL\ndeck: Rain falls.\nbreaking: true\n" \
                         "correction: An earlier version misstated the date.\nsources: [{title: Agency, url: 'https://example.com'}]\nfeatured: true\n",
    "2026-10-05-k.md" => "title: 가나\nlang: ko\ntags: [x]\n"
  }.freeze

  def self.site
    @site ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      %w[_posts _data ko].each { |d| FileUtils.mkdir_p(File.join(src, d)) }
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: Site\nlang: en\nurl: https://example.org\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\n" \
        "sass: {style: compressed, silence_deprecations: [import, global-builtin]}\nmodootoday: {feed: true, archive: {tags: /tags/, categories: /categories/}, news: {sections: [world]}}\n" \
        "defaults: [{scope: {path: ''}, values: {layout: doc}}, {scope: {path: ko}, values: {lang: ko}}, {scope: {type: posts}, values: {layout: post}}]\n")
      File.write(File.join(src, "_data/authors.yml"), "jane: {name: Jane Roe, url: /authors/jane/, bio: Writes things.}\n")
      File.write(File.join(src, "blog.md"), "---\nlayout: blog\ntitle: Blog\nvariant: magazine\n---\n# Blog\n")
      File.write(File.join(src, "news.md"), "---\nlayout: news\ntitle: News\nsecondary: 1\n---\n")
      File.write(File.join(src, "feed.xml"), "---\nlayout: feed\n---\n")
      File.write(File.join(src, "ko/feed.xml"), "---\nlayout: feed\n---\n")
      File.write(File.join(src, "authors/jane.md").tap { |f| FileUtils.mkdir_p(File.dirname(f)) }, "---\nlayout: author\nauthor: jane\n---\n")
      POSTS.each { |f, fm| File.write(File.join(src, "_posts", f), "---\n#{fm}---\nBody text for #{f}.\n\n## Part\n\nMore.\n") }
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      dir
    end
  end

  def read(rel) = File.read(File.join(self.class.site, "_site", rel))

  def test_blog_index_cards_variant_and_language
    h = read("blog/index.html")
    assert_includes h, '<div class="mt-post-list" data-variant="magazine">'
    assert_equal 3, h.scan(/<article class="mt-card-post/).size
    assert_includes h, "mt-card-post-featured"
    refute_includes h, "가나", "other-language posts are filtered out"
    assert_operator h.index("Storm"), :<, h.index("Alpha"), "newest first"
    assert_includes h, "modootoday-blog.css"
  end

  def test_news_front_lead_latest_sections
    h = read("news/index.html")
    lead = h[/<div class="mt-news-lead".*?<\/article>/m]
    assert_includes lead, "Storm"
    assert_includes lead, 'data-variant="breaking"'
    assert_includes h, 'data-category="world"'
    assert_includes h, 'id="mt-news-latest"'
    refute_includes h, '<a href=""'
  end

  def test_blog_bundle_budgets
    require "zlib"
    js = File.read(File.join(ROOT, "assets/js/modootoday/share.js"))
    assert_operator js.bytesize, :<=, 1024, "share.js: blog-js budget is 1 KB"
    css = read("assets/css/modootoday-blog.css")
    assert_operator css.bytesize, :<=, 8 * 1024, "modootoday-blog.css: blog-css budget is 8 KB"
  end

  def test_post_parts
    h = read("world/2026/10/01/a/index.html")
    assert_includes h, '<a class="mt-post-author" rel="author" href="/authors/jane/">Jane Roe</a>'
    assert_includes h, '<meta property="og:image" content="https://example.org/a.png">'
    assert_includes h, 'alt="A chart"'
    assert_includes h, "<figcaption>Source A</figcaption>"
    assert_includes h, "Part 1 of 2"
    assert_match(/min read/, h)
    assert_includes h, 'rel="next" href="/world/2026/10/02/b/"'
    assert_includes h, 'class="mt-related"'
    assert_includes h, '<meta property="article:tag" content="x">'
    ld = JSON.parse(h[%r{<script type="application/ld\+json">(.*?)</script>}m, 1])["@graph"].find { |n| n["@id"].end_with?("#main") }
    assert_equal "BlogPosting", ld["@type"]
    assert_equal "Jane Roe", ld["author"][0]["name"]
    %w[headline datePublished dateModified mainEntityOfPage image].each { |k| assert ld[k], k }
  end

  def test_news_article
    h = read("world/2026/10/04/n/index.html")
    ld = JSON.parse(h[%r{<script type="application/ld\+json">(.*?)</script>}m, 1])["@graph"].find { |n| n["@id"].end_with?("#main") }
    assert_equal "NewsArticle", ld["@type"]
    assert_equal ["Jane Roe", "bob"], ld["author"].map { |a| a["name"] }
    assert_includes h, '<span class="mt-dateline">SEOUL</span>'
    assert_includes h, '<p class="mt-post-deck" data-part="deck">Rain falls.</p>'
    assert_includes h, "mt-news-correction"
    assert_includes h, '<a href="https://example.com">Agency</a>'
  end

  def test_author_page
    h = read("authors/jane/index.html")
    assert_includes h, "<h1>Jane Roe</h1>"
    assert_includes h, "Alpha"
    refute_includes h, ">Beta<"
  end

  def test_feeds_are_valid_atom_per_language
    en = REXML::Document.new(read("feed.xml"))
    assert_equal "feed", en.root.name
    titles = en.root.get_elements("entry/title").map(&:text)
    assert_equal %w[Storm Beta Alpha], titles
    ko = REXML::Document.new(read("ko/feed.xml"))
    assert_equal ["가나"], ko.root.get_elements("entry/title").map(&:text)
    assert_includes read("2026/10/05/k/index.html"), 'href="/ko/feed.xml"'
  end

  def test_blog_css_builds_separately
    css = read("assets/css/modootoday-blog.css")
    assert_includes css, ".mt-card-post"
    refute_includes css, "--mt-primary:", "the blog bundle emits no tokens"
    refute_includes read("assets/css/modootoday.css"), ".mt-card-post"
  end
end
