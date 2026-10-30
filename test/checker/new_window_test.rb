# frozen_string_literal: true
# New-window and demo-link rules (lib/modootoday/check/a11y/new_window.rb). Run: bundle exec rake test
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class NewWindowCheckTest < Minitest::Test
  CHECK = File.expand_path("../../exe/modootoday-check", __dir__)
  ENV0 = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze

  def run_on(body, fm: "", html: nil)
    Dir.mktmpdir do |d|
      FileUtils.mkdir_p(["#{d}/src", "#{d}/_site"])
      File.write("#{d}/src/p.md", "---\ntitle: P\n#{fm}---\n#{body}")
      File.write("#{d}/_site/p.html", html) if html
      out, = Open3.capture2e(ENV0, RbConfig.ruby, CHECK, "#{d}/src", "#{d}/_site")
      out
    end
  end

  def test_blank_without_noopener_is_error = assert_match(/without rel="noopener"/, run_on("<a href=\"https://x.test\" target=\"_blank\">X</a>\n"))
  def test_blank_without_hint_warns = assert_match(/without the spoken hint/, run_on("<a href=\"https://x.test\" target=\"_blank\" rel=\"noopener\">X</a>\n"))
  def test_title_marker_ok = refute_match(/new-window link|noopener/, run_on("[X](https://x.test \"new-window\")\n"))
  def test_new_window_value = assert_match(/new_window: must be true or false/, run_on("A\n", fm: "items:\n  - {title: A, url: \"#\", new_window: yes}\n"))
  def test_demo_external_link_warns = assert_match(/leaves the sample/, run_on("[Docs](https://x.test/)\n", fm: "noindex: true\n"))
  def test_demo_empty_link_warns = assert_match(/no target/, run_on("A\n", fm: "noindex: true\nitems:\n  - {\"title\": \"A\", \"url\": \"\"}\n"))
  def test_demo_hash_ok = refute_match(/leaves the sample|no target/, run_on("[Docs](#)\n", fm: "noindex: true\n"))
  def test_normal_page_external_ok = refute_match(/leaves the sample/, run_on("[Docs](https://x.test/)\n"))

  def test_built_root_link_in_demo_warns
    html = "<meta name=\"robots\" content=\"noindex\"><main><a href=\"/base/#\">A</a></main>"
    assert_match(/resolves to the site root/, run_on("A\n", html: html))
  end

  def test_built_blank_without_noopener_is_error
    assert_match(/p.html: target="_blank" without rel/, run_on("A\n", html: "<a href=\"https://x.test\" target=\"_blank\">X</a>"))
  end
end
