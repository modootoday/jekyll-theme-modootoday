# frozen_string_literal: true
# modootoday.showcase in _config.yml and in the demo overlay _config.demo.yml, and the noindex of a showcase build.
require_relative "../checker_case"

class CheckShowcaseTest < CheckerCase
  DOCS = "https://modootoday.github.io/jekyll-theme-modootoday/"

  def test_demo_overlay_values_are_checked
    page "_config.demo.yml", "modootoday:\n  showcase: {enabled: maybe, style: banner, docs_url: http://x.test/, use_url: /gen, " \
                             "starter: 'a b', colour: red}\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "_config.demo.yml: modootoday.showcase: unknown key 'colour'"
    assert_includes o, "_config.demo.yml: modootoday.showcase.enabled must be true or false"
    assert_includes o, "modootoday.showcase.style must be bar or pill"
    assert_includes o, "modootoday.showcase.docs_url must be an https:// URL"
    assert_includes o, "modootoday.showcase.use_url must be an https:// URL"
    assert_includes o, "modootoday.showcase.starter must be a name"
  end

  def test_enabled_without_docs_url_and_an_unlabelled_starter
    page "_config.demo.yml", "modootoday:\n  showcase: {enabled: true, starter: saas}\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "docs_url is required when enabled is true"
    assert_includes o, "warning: _config.demo.yml: modootoday.showcase.starter 'saas' has no showcase.starters.saas label"
  end

  def test_a_site_catalog_can_label_its_own_starter
    page "_config.demo.yml", "modootoday:\n  showcase: {enabled: true, starter: saas, docs_url: #{DOCS}}\n"
    page "_data/i18n/en.yml", "showcase:\n  starters: {saas: SaaS starter}\n"
    o, code = check("--strict")
    assert_equal 0, code, o
  end

  def test_enabled_in_config_yml_warns_that_copies_inherit_it
    page "_config.yml", "modootoday:\n  showcase: {enabled: true, style: pill, starter: blog, docs_url: #{DOCS}}\n"
    o, = check
    assert_includes o, "warning: _config.yml: modootoday.showcase.enabled: sites made from this one show it too"
    page "_config.yml", "modootoday:\n  showcase: maybe\n"
    assert_includes check[0], "modootoday.showcase must be a map"
  end

  def test_built_pages_without_noindex_warn_only_when_enabled
    out "a/index.html", "<html data-mt-showcase=\"bar\"><head><meta name=\"robots\" content=\"noindex\"></head><body></body></html>"
    out "b/index.html", "<html><head><title>B</title></head><body></body></html>"
    assert_equal 0, check("--strict")[1]
    page "_config.demo.yml", "modootoday:\n  showcase: {enabled: true, docs_url: #{DOCS}}\n"
    o, = check
    assert_includes o, "b/index.html: no robots noindex meta although modootoday.showcase is enabled"
    refute_includes o, "a/index.html"
  end

  def test_a_build_without_the_demo_overlay_reports_nothing
    page "_config.demo.yml", "modootoday:\n  showcase: {enabled: true, docs_url: #{DOCS}}\n"
    out "index.html", "<html><head><title>A</title></head><body></body></html>"
    o, code = check("--strict")
    assert_equal 0, code, o
  end
end
