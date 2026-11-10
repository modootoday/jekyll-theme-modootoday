# frozen_string_literal: true
# modootoday-check: the event tickets: contract of the detail layouts (lib/modootoday/check/layouts/detail.rb).
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class DetailCheckTest < Minitest::Test
  CHECK = File.expand_path("../../../exe/modootoday-check", __dir__)
  CLEAN_ENV = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze
  EVENT = "layout: event\nstarts: 2026-11-20 19:00\nvenue: Hall A\n"
  HINT = "tickets: give {url, price, currency} so the event offer has a price (a nested offer without one is an error in the next major version)"

  def setup
    @dir = Dir.mktmpdir
    @src, @site = File.join(@dir, "src"), File.join(@dir, "_site")
    FileUtils.mkdir_p([@src, @site])
  end

  def teardown = FileUtils.rm_rf(@dir)

  def event(tickets) = File.write(File.join(@src, "e.md"), "---\ntitle: T\n#{EVENT}#{tickets}---\nBody.\n")

  def check
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, @src, @site)
    [o + e, st.exitstatus]
  end

  def test_map_with_price_passes_without_warning
    ["tickets: {url: /t/, price: 0, currency: KRW}\n", "tickets: {url: 'https://x.test/t', price: 12.5, currency: USD}\n"].each do |t|
      event t
      o, code = check
      assert_equal 0, code, o
      refute_includes o, HINT
    end
  end

  def test_string_warns_with_the_fix
    event "tickets: /t/\n"
    o, code = check
    assert_equal 0, code, o
    assert_includes o, "e.md: layout event: #{HINT}"
  end

  def test_map_without_price_warns
    event "tickets: {url: /t/}\n"
    o, code = check
    assert_equal 0, code, o
    assert_includes o, HINT
  end

  def test_schema_offers_silences_the_warning
    event "tickets: /t/\nschema: {offers: {type: Offer, price: 0, priceCurrency: KRW}}\n"
    o, code = check
    assert_equal 0, code, o
    refute_includes o, HINT
  end

  def test_map_shape_errors
    {
      "tickets: {url: /t/, price: 0, currency: KRW, kind: vip}\n" => "tickets has unknown key 'kind' (url, price, currency)",
      "tickets: {price: 0, currency: KRW}\n" => "tickets.url must be a site path or full URL",
      "tickets: {url: /t/, price: -1, currency: KRW}\n" => "tickets.price must be a number of 0 or more",
      "tickets: {url: /t/, price: '10', currency: KRW}\n" => "tickets.price must be a number of 0 or more",
      "tickets: {url: /t/, price: 10, currency: won}\n" => "tickets.currency must be an ISO 4217 code such as KRW or USD",
      "tickets: {url: /t/, price: 10}\n" => "tickets needs price and currency together, or neither",
      "tickets: {url: /t/, currency: KRW}\n" => "tickets needs price and currency together, or neither",
      "tickets: tickets.html\n" => "tickets must be a site path or full URL, or a map of url, price and currency",
    }.each do |t, msg|
      event t
      o, code = check
      assert_equal 1, code, "#{t}#{o}"
      assert_includes o, "e.md: layout event: #{msg}", t
    end
  end
end
