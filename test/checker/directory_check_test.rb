# frozen_string_literal: true
# modootoday-check: front matter contract of the directory layouts (lib/modootoday/check/layouts/directory.rb).
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class DirectoryCheckTest < Minitest::Test
  CHECK = File.expand_path("../../exe/modootoday-check", __dir__)
  CLEAN_ENV = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze

  def setup
    @dir = Dir.mktmpdir
    @src, @site = File.join(@dir, "src"), File.join(@dir, "_site")
    FileUtils.mkdir_p([@src, @site, File.join(@src, "_data")])
  end

  def teardown = FileUtils.rm_rf(@dir)

  def page(fm) = File.write(File.join(@src, "d.md"), "---\ntitle: T\nsections: []\n#{fm}---\nBody.\n")

  def check
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, @src, @site)
    [o + e, st.exitstatus]
  end

  def assert_fails(fm, msg)
    page fm
    o, code = check
    assert_equal 1, code, o
    assert_includes o, msg
  end

  def test_valid_presets_pass
    page "layout: team\nitems:\n  - {name: Ada, role: Founder, group: Lead, image: /a.png, alt: \"\"}\n"
    assert_equal 0, check[1]
    page "layout: events\nitems:\n  - {title: Meetup, date: 2026-11-20 19:00, url: \"https://x.test/\"}\n"
    assert_equal 0, check[1]
  end

  def test_data_file
    File.write(File.join(@src, "_data", "jobs.yml"), "- {title: Engineer, department: Eng}\n")
    page "layout: jobs\ndata: jobs\n"
    o, code = check
    assert_equal 0, code, o
    assert_fails "layout: jobs\ndata: nope\n", "data: nope has no file in _data"
  end

  def test_items_or_data_required = assert_fails("layout: portfolio\n", "set items: (a list) or data:")
  def test_item_needs_name = assert_fails("layout: team\nitems:\n  - {role: X}\n", "items[0] needs title or name")
  def test_event_needs_date = assert_fails("layout: events\nitems:\n  - {title: A}\n", "items[0].date must be a date")
  def test_bad_url = assert_fails("layout: sponsors\nitems:\n  - {name: A, url: example.com}\n", "items[0].url must be")
  def test_unknown_preset = assert_fails("layout: directory\npreset: gallery\nitems: []\n", "preset must be one of")
end
