# frozen_string_literal: true
# SEO/head options (canonical, hreflang, Open Graph, feed link), modootoday.csp: strict and the
# optional page footer (edit link, last updated), built on the example site with an overlay config.
require "minitest/autorun"
require "tmpdir"
require "open3"

class HeadMetaTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  EXAMPLE = File.join(ROOT, "example")
  INLINE = "<script>try{var t=localStorage"

  def build(dir, overlay)
    File.write("#{dir}/o.yml", overlay)
    out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", EXAMPLE, "-d", "#{dir}/s",
                              "--config", "#{EXAMPLE}/_config.yml,#{dir}/o.yml", chdir: ROOT)
    assert st.success?, out
    "#{dir}/s"
  end

  def test_defaults_include_og_and_inline_prepaint_but_no_canonical_without_url
    Dir.mktmpdir do |d|
      html = File.read("#{build(d, "x: 1\n")}/guide/index.html")
      assert_includes html, '<meta property="og:title"'
      assert_includes html, '<meta name="twitter:card" content="summary">'
      assert_includes html, INLINE
      refute_includes html, 'rel="canonical"'
      refute_includes html, "hreflang"
      refute_includes html, "mt-page-meta"
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
          edit_url: https://github.com/o/r/edit/main/example/
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
        assert_includes h, '<script src="/docs/assets/js/modootoday/theme-init.js"></script>'
        refute_includes h, INLINE
        refute_match(/<script>(?!<\/script>)/, h, "no inline script with csp: strict")
      end
      assert_includes ko, '<meta property="og:locale" content="ko">'
      refute_includes File.read("#{s}/guide/index.html"), 'hreflang="ko"', "guide has no ko translation"
      assert_includes en, 'href="https://github.com/o/r/edit/main/example/index.md"'
      assert File.exist?("#{s}/assets/js/modootoday/theme-init.js")
    end
  end

  def test_seo_false_drops_meta
    Dir.mktmpdir do |d|
      html = File.read("#{build(d, "url: https://example.org\nmodootoday: {seo: false}\n")}/index.html")
      refute_includes html, "og:title"
      refute_includes html, 'rel="canonical"'
    end
  end
end
