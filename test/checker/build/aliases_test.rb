# frozen_string_literal: true
# --aliases (lib/modootoday/check/build/aliases.rb): missing aliases, byte mismatch, redirect target, conflicts.
require_relative "../checker_case"

class CheckAliasesTest < CheckerCase
  REDIRECT = %(<link rel="canonical" href="%s">\n<meta http-equiv="refresh" content="0; url=%s">\n)

  def setup
    super
    write File.join(@src, "_config.yml"), "baseurl: /site\nmodootoday: {aliases: {md: true, html: true}}\n"
    page "index.md", "---\n---\n# Home\n"
    page "g.md", "---\n---\n# G\n"
    page "404.md", "---\npermalink: /404.html\n---\n# Gone\n"
  end

  def aliases_errors = check("--aliases")[0].lines.grep(/alias|aliases/).join

  def test_missing_aliases
    o = aliases_errors
    assert_match(%r{g\.md: md alias missing at .*/g\.md: run modootoday-stubs SRC --aliases --write}, o)
    assert_match(%r{g\.md: html alias missing at .*/g\.html}, o)
    refute_match(/index\.md:|404/, o)
  end

  def test_md_alias_must_match_the_twin_byte_for_byte
    out "g/index.md", "# G\n"
    out "g.md", "# G changed\n"
    assert_match(/g\.md: md alias is not byte-identical to the twin of g\.md/, aliases_errors)
    out "g.md", "# G\n"
    refute_match(/md alias/, aliases_errors)
  end

  def test_html_alias_redirect_and_canonical
    out "g.html", format(REDIRECT, "https://example.test/site/other/", "/site/other/")
    o = aliases_errors
    assert_match(%r{html alias must redirect to /site/g/ \(got "/site/other/"\)}, o)
    assert_match(%r{html alias canonical must be the page URL /site/g/}, o)
    out "g.html", format(REDIRECT, "https://example.test/site/g/", "/site/g/")
    refute_match(/html alias/, aliases_errors)
  end

  def test_html_alias_without_baseurl_takes_the_prefix_of_the_build
    write File.join(@src, "_config.yml"), "modootoday: {aliases: {html: true}}\n"
    out "g.html", format(REDIRECT, "https://example.test/repo/g/", "/repo/g/")
    refute_match(/html alias/, aliases_errors)
    out "g.html", format(REDIRECT, "https://example.test/other/g/", "/repo/g/")
    assert_match(%r{canonical must be the page URL /repo/g/}, aliases_errors)
  end

  def test_conflicts
    page "h/index.md", "---\n---\n# H\n"
    page "x.md", "---\npermalink: /h/\n---\n# X\n"
    page "g.html", "<p>hand-written</p>\n"
    o = aliases_errors
    assert_match(%r{x\.md: alias /h\.md is also the alias of h/index\.md}, o)
    assert_match(%r{g\.md: alias /g\.html collides with the source file g\.html}, o)
  end

  def test_declaration_is_required_and_md_is_refused_in_source_mode
    write File.join(@src, "_config.yml"), "modootoday: {twins: source, aliases: {md: true}}\n"
    o = check("--aliases")[0]
    assert_match(/modootoday\.aliases\.md cannot be used with twins: source/, o)
    write File.join(@src, "_config.yml"), "modootoday: {aliases: {md: false}}\n"
    assert_match(/--aliases: modootoday\.aliases declares no alias/, check("--aliases")[0])
    write File.join(@src, "_config.yml"), "modootoday: {aliases: {md: yes please}}\n"
    assert_match(/modootoday\.aliases must be a map of md and html/, check[0])
  end
end
