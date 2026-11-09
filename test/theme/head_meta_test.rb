# frozen_string_literal: true
# SEO/head options (canonical, hreflang, Open Graph, feed link), modootoday.csp: strict and the
# optional page footer (edit link, last updated), built on the docs starter with an overlay config.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require_relative "../support/starters"

class HeadMetaTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  DOCS = Starters::Sources.path("docs")
  INLINE = "<script>try{var t=localStorage"

  def build(dir, overlay)
    File.write("#{dir}/o.yml", overlay)
    out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", DOCS, "-d", "#{dir}/s",
                              "--config", "#{DOCS}/_config.yml,#{dir}/o.yml", chdir: ROOT)
    assert st.success?, out
    "#{dir}/s"
  end

  def test_defaults_include_og_and_inline_prepaint_but_no_canonical_without_url
    Dir.mktmpdir do |d|
      html = File.read("#{build(d, "modootoday: {languages: [en], csp: false}\n")}/guide/index.html")
      assert_includes html, '<meta property="og:title"'
      assert_includes html, '<meta name="twitter:card" content="summary">'
      assert_includes html, INLINE
      refute_includes html, 'rel="canonical"'
      refute_includes html, "hreflang"
      refute_includes html, "mt-page-meta"
      assert_includes html, '<meta name="theme-color" media="(prefers-color-scheme: dark)" content="#0a0a0a">'
    end
  end

  def test_all_options
    Dir.mktmpdir do |d|
      s = build(d, <<~YML)
        url: https://example.org
        baseurl: /docs
        modootoday:
          languages: [en, ko, ja]
          csp: strict
          feed: true
          og_image: /assets/og.png
          edit_url: https://github.com/o/r/edit/main/site/
      YML
      en = File.read("#{s}/index.html")
      ko = File.read("#{s}/ko/index.html")
      assert_includes en, '<link rel="canonical" href="https://example.org/docs/">'
      [en, ko].each do |h|
        assert_includes h, '<link rel="alternate" hreflang="en" href="https://example.org/docs/">'
        assert_includes h, '<link rel="alternate" hreflang="ko" href="https://example.org/docs/ko/">'
        assert_includes h, '<link rel="alternate" hreflang="x-default" href="https://example.org/docs/">'
        assert_includes h, 'href="/docs/feed.xml"'
        assert_includes h, '<meta property="og:image" content="https://example.org/docs/assets/og.png">'
        assert_match %r{<script src="/docs/assets/js/modootoday/chrome/theme-init\.js\?v=[^"]+"></script>}, h
        refute_includes h, INLINE
        refute_match(/<script>(?!<\/script>)/, h, "no inline script with csp: strict")
      end
      assert_includes ko, '<meta property="og:locale" content="ko">'
      guide = File.read("#{s}/guide/index.html")
      %w[ko ja].each do |l|
        assert_includes guide, %(<link rel="alternate" hreflang="#{l}" href="https://example.org/docs/#{l}/guide/">)
        assert_includes File.read("#{s}/#{l}/guide/index.html"), %(<link rel="alternate" hreflang="en" href="https://example.org/docs/guide/">)
      end
      assert_includes en, 'href="https://github.com/o/r/edit/main/site/index.md"'
      assert File.exist?("#{s}/assets/js/modootoday/chrome/theme-init.js")
    end
  end

  def test_seo_false_drops_meta
    Dir.mktmpdir do |d|
      html = File.read("#{build(d, "url: https://example.org\nmodootoday: {seo: false}\n")}/index.html")
      refute_includes html, "og:title"
      refute_includes html, 'rel="canonical"'
    end
  end

  def test_brand_link_points_to_the_language_home
    Dir.mktmpdir do |d|
      s = build(d, "baseurl: /docs\nmodootoday:\n  languages: [en, ko, ja]\n")
      brand = ->(f) { File.read("#{s}/#{f}")[/class="mt-site-title[^"]*" href="([^"]*)"/, 1] }
      assert_equal "/docs/", brand.("guide/index.html")
      assert_equal "/docs/ko/", brand.("ko/guide/index.html")
      assert_equal "/docs/ja/", brand.("ja/index.html")
    end
  end

  # _data/i18n/<lang>.yml site_title names the site per language; site.title is the fallback.
  def test_localized_site_title
    Dir.mktmpdir do |d|
      src = "#{d}/src"
      FileUtils.cp_r(DOCS, src)
      FileUtils.rm_rf("#{src}/_site")
      File.write("#{src}/_data/i18n/ko.yml", "site_title: 모두의오늘 테마\n")
      out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", src, "-d", "#{d}/s", chdir: ROOT)
      assert st.success?, out
      ko = File.read("#{d}/s/ko/index.html")
      assert_match(%r{<title>[^<]*모두의오늘 테마</title>}, ko)
      assert_match(/class="mt-site-title[^"]*"[^>]*>(?:<svg.*?<\/svg>)?\s*<span class="mt-site-name">모두의오늘 테마<\/span><\/a>/m, ko)
      assert_includes ko, '<meta property="og:site_name" content="모두의오늘 테마">'
      title = File.read("#{src}/_config.yml")[/^title:\s*(.+)$/, 1].delete('"')
      assert_includes File.read("#{d}/s/index.html"), "#{title}</title>"
      assert_includes File.read("#{d}/s/index.html"), %(<span class="mt-site-name">#{title.gsub(".", ".<wbr>")}</span>), "a dotted name may break after a dot"
    end
  end
end
