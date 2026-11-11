# frozen_string_literal: true
# --links (lib/modootoday/check/build/links.rb): same-site links and anchors in the built site, warnings unless --strict.
require_relative "../checker_case"

class CheckLinksTest < CheckerCase
  def setup
    super
    write File.join(@src, "_config.yml"), "baseurl: /site\n"
    page "index.md", "---\n---\n# Home\n"
    out "index.html", %(<html><body><h2 id="top">Top</h2><a href="/site/guide/">Guide</a></body></html>)
    out "guide/index.html", %(<html><body><h2 id="設定">設定</h2><a name="old"></a></body></html>)
  end

  def warnings(*flags)
    check("--links", *flags)[0]
  end

  def link(href) = out("p/index.html", %(<html><body><a href="#{href}">x</a></body></html>))

  def test_a_missing_page_warns_and_strict_fails
    link "/site/nowhere/"
    o, code = check("--links")
    assert_equal 0, code, o
    assert_match(%r{p/index\.html: broken link /site/nowhere/}, warnings)
    o, code = check("--links", "--strict")
    assert_equal 1, code
    assert_match(%r{p/index\.html: broken link /site/nowhere/ \[strict\]}, o)
  end

  def test_a_missing_anchor_warns
    link "/site/guide/#nope"
    assert_match(%r{missing anchor /site/guide/#nope}, warnings)
  end

  def test_a_percent_encoded_cjk_anchor_and_a_name_resolve
    link "/site/guide/#%E8%A8%AD%E5%AE%9A"
    refute_match(/broken|missing/, warnings)
    link "../guide/#old"
    refute_match(/broken|missing/, warnings)
  end

  def test_query_strings_and_same_page_fragments
    out "p/index.html", %(<html><body><h2 id="here">h</h2><a href="/site/guide/?q=1#old">x</a><a href="#here">y</a></body></html>)
    refute_match(/broken|missing/, warnings)
  end

  def test_links_outside_baseurl_and_external_urls
    link "/elsewhere/"
    assert_match(%r{/elsewhere/ is outside baseurl /site}, warnings)
    link "https://example.com/missing"
    refute_match(/example\.com/, warnings)
  end

  def test_alias_redirect_pages_and_twins_resolve
    out "guide.html", %(<html><head><link rel="canonical" href="/site/guide/"></head></html>)
    out "guide/index.md", "# Guide\n"
    out "p/index.html", %(<html><body><a href="/site/guide.html">a</a><a href="/site/guide/index.md">t</a></body></html>)
    refute_match(/broken|missing/, warnings)
  end

  def test_without_the_option_nothing_is_checked
    link "/site/nowhere/"
    refute_match(/broken link/, check[0])
  end
end
