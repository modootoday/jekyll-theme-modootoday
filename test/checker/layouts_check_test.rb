# frozen_string_literal: true
# modootoday-check: front matter contract of the page-shell layouts (lib/modootoday/check/layouts.rb).
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class LayoutsCheckTest < Minitest::Test
  CHECK = File.expand_path("../../exe/modootoday-check", __dir__)
  CLEAN_ENV = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze

  def setup
    @dir = Dir.mktmpdir
    @src, @site = File.join(@dir, "src"), File.join(@dir, "_site")
    FileUtils.mkdir_p([@src, @site])
  end

  def teardown = FileUtils.rm_rf(@dir)

  def page(name, fm) = File.write(File.join(@src, name), "---\ntitle: T\nsections: []\n#{fm}---\nBody.\n")

  def check
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, @src, @site)
    [o + e, st.exitstatus]
  end

  def test_valid_shells_pass
    page "e.md", "layout: error\nstatus: 410\n"
    page "r.md", "layout: redirect\nredirect_to: /new/\n"
    page "h.md", "layout: home\nhero: {title: Hi, actions: [{label: Go, url: /go/}]}\n"
    page "m.md", "layout: minimal\n"
    o, code = check
    assert_equal 0, code, o
  end

  def test_error_status_must_be_known
    page "e.md", "layout: error\nstatus: 403\n"
    o, code = check
    assert_equal 1, code, o
    assert_includes o, "e.md: layout error: status must be one of 404, 410, 500"
  end

  def test_redirect_needs_target
    page "r.md", "layout: redirect\n"
    o, = check
    assert_includes o, "r.md: layout redirect: redirect_to is required"
  end

  def test_home_hero_shape
    page "h.md", "layout: home\nhero: {text: x, button: y, actions: [{label: Go}]}\n"
    o, = check
    assert_includes o, "hero has unknown key 'button'"
    assert_includes o, "hero.title is required"
    assert_includes o, "hero.actions[0] needs label and url"
  end

  def test_search_fallback_must_be_https
    File.write(File.join(@src, "_config.yml"), "modootoday:\n  search:\n    fallback: {url: 'http://x.test/'}\n")
    page "s.md", "layout: search\n"
    o, = check
    assert_includes o, "modootoday.search.fallback.url must be an https URL"
  end
end
