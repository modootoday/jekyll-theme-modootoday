# frozen_string_literal: true
# Screen-reader authoring rules (lib/modootoday/check/a11y/content.rb). Run: bundle exec rake test
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class A11yCheckTest < Minitest::Test
  CHECK = File.expand_path("../../exe/modootoday-check", __dir__)
  ENV0 = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze

  def run_on(body)
    Dir.mktmpdir do |d|
      FileUtils.mkdir_p(["#{d}/src", "#{d}/_site"])
      File.write("#{d}/src/p.md", "---\ntitle: P\n---\n#{body}")
      out, = Open3.capture2e(ENV0, RbConfig.ruby, CHECK, "#{d}/src", "#{d}/_site")
      out
    end
  end

  def test_img_without_alt_is_error = assert_match(/<img> without alt/, run_on("<img src=\"a.png\">\n"))
  def test_img_with_alt_ok = refute_match(/without alt/, run_on("<img src=\"a.png\" alt=\"\">\n"))
  def test_empty_link_is_error = assert_match(/empty link text/, run_on("See [](https://x.test).\n"))
  def test_vague_link_warns = assert_match(/vague link text "click here"/, run_on("[click here](https://x.test)\n"))
  def test_heading_skip_warns = assert_match(/jumps from h2 to h4/, run_on("## A\n\n#### B\n"))
  def test_heading_order_ok = refute_match(/jumps/, run_on("## A\n\n### B\n\n## C\n"))
  def test_duplicate_id_is_error = assert_match(/duplicate id="x"/, run_on("<span id=\"x\">a</span>\n\n<span id=\"x\">b</span>\n"))
  def test_code_is_ignored = refute_match(/without alt/, run_on("```html\n<img src=\"a.png\">\n```\n"))
end
