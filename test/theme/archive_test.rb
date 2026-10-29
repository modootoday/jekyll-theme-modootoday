# frozen_string_literal: true
# Tag/category archive: include + layout (Liquid only), language filter, post footer links, checker config rule.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "jekyll"

class ArchiveTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)

  def self.site
    @site ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(File.join(src, "_posts"))
      FileUtils.mkdir_p(File.join(src, "ko"))
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: Site\nlang: en\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\nsass: {silence_deprecations: [import, global-builtin]}\n" \
                                                "modootoday: {archive: {tags: /tags/, categories: /categories/}}\n" \
                                                "defaults: [{scope: {path: ''}, values: {layout: doc}}, {scope: {path: ko}, values: {lang: ko}}, {scope: {type: posts}, values: {layout: post}}]\n")
      File.write(File.join(src, "tags.md"), "---\ntitle: Tags\nlayout: archive\n---\n# Tags\n")
      File.write(File.join(src, "categories.md"), "---\ntitle: Categories\nlayout: archive\narchive: categories\n---\n# Categories\n")
      File.write(File.join(src, "all.md"), "---\ntitle: All\nlayout: archive\narchive_lang: all\n---\n# All\n")
      File.write(File.join(src, "ko/tags.md"), "---\ntitle: 태그\nlayout: archive\n---\n# 태그\n")
      File.write(File.join(src, "inc.md"), "---\ntitle: Inc\n---\n# Inc\n\n{% include modootoday/archive.html by=\"categories\" %}\n")
      File.write(File.join(src, "_posts/2026-10-01-a.md"), "---\ntitle: A & B\ncategories: [guides]\ntags: [news, Big Data]\n---\n# A\n")
      File.write(File.join(src, "_posts/2026-10-05-b.md"), "---\ntitle: B\ntags: [news]\n---\n# B\n")
      File.write(File.join(src, "_posts/2026-10-06-k.md"), "---\ntitle: 가\nlang: ko\ntags: [소식]\n---\n# 가\n")
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      dir
    end
  end

  def read(rel) = File.read(File.join(self.class.site, "_site", rel))

  def test_tag_archive_index_counts_and_groups
    h = read("tags/index.html")
    assert_includes h, '<nav class="mt-archive-index" aria-label="Tags">'
    assert_match %r{<a class="mt-badge mt-badge-tag" data-variant="tag" href="#tags-news"><svg class="mt-icon mt-icon-tag"[^>]*>.*?</svg>news <span class="mt-archive-count">2<span class="mt-sr-only"> posts</span></span></a>}, h
    assert_includes h, 'href="#tags-big-data"'
    assert_includes h, '<h2 id="tags-news">news</h2>'
    news = h[/<h2 id="tags-news">.*?<\/section>/m]
    assert_operator news.index("/2026/10/05/b/"), :<, news.index("/2026/10/01/a/"), "newest first"
    assert_includes h, "A &amp; B"
    refute_includes h, "소식", "other-language posts are filtered out"
  end

  def test_language_filter_and_all
    assert_includes read("ko/tags/index.html"), 'id="tags-소식"'
    refute_includes read("ko/tags/index.html"), "tags-news"
    all = read("all/index.html")
    assert_includes all, "tags-news"
    assert_includes all, "tags-소식"
  end

  def test_category_archive_layout_and_include
    [read("categories/index.html"), read("inc/index.html")].each do |h|
      assert_includes h, '<div class="mt-archive" data-by="categories">'
      assert_includes h, '<h2 id="categories-guides">guides</h2>'
    end
  end

  def test_post_footer_links
    h = read("guides/2026/10/01/a/index.html")
    assert_includes h, '<footer class="mt-post-terms">'
    assert_includes h, 'href="/categories/#categories-guides">guides</a>'
    assert_includes h, 'href="/tags/#tags-big-data">Big Data</a>'
    assert_includes read("2026/10/06/k/index.html"), 'href="/ko/tags/#tags-소식"'
  end

  def test_checker_rejects_bad_archive_config
    Dir.mktmpdir do |d|
      FileUtils.mkdir_p(File.join(d, "_site"))
      File.write(File.join(d, "_config.yml"), "modootoday: {archive: {tags: tags}}\n")
      File.write(File.join(d, "index.md"), "---\ntitle: x\n---\n# x\n")
      out, st = Open3.capture2e(RbConfig.ruby, File.join(ROOT, "exe/modootoday-check"), d, File.join(d, "_site"))
      refute st.success?
      assert_includes out, "modootoday.archive.tags must be a site path"
    end
  end
end
