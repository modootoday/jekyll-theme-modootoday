# frozen_string_literal: true
# modootoday-check rules for the 1.0 content components (inline values and per-section content).
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class ComponentRulesTest < Minitest::Test
  CHECK = File.expand_path("../../exe/modootoday-check", __dir__)
  CLEAN_ENV = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze

  def setup
    @dir = Dir.mktmpdir
    FileUtils.mkdir_p(%w[src _site].map { |d| File.join(@dir, d) })
  end

  def teardown = FileUtils.rm_rf(@dir)

  def check(md, config = nil)
    File.write(File.join(@dir, "src/a.md"), md)
    File.write(File.join(@dir, "src/_config.yml"), config) if config
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, File.join(@dir, "src"), File.join(@dir, "_site"))
    [o + e, st.exitstatus]
  end

  def page(sections, body) = "---\ntitle: A\nsections: #{sections}\n---\n# A\n\n#{body}"

  def test_good_inline_values_pass
    out, st = check("---\ntitle: A\n---\n# A\n\n`progress:100` `skeleton:row` `loading:bar`\n\n`embed:https://e.x/v T`\n\n`file:a.rb`\n\n```ruby\n1\n```\n")
    assert_equal 0, st, out
  end

  def test_bad_inline_values_fail
    out, st = check("---\ntitle: A\n---\n# A\n\n`progress:101` `skeleton:circle`\n\n`embed:http://e.x/v`\n\n`file:a.rb`\n\ntext\n")
    assert_equal 1, st
    %w[progress:101 skeleton:circle embed:http file:a.rb].each { |w| assert_includes out, w }
  end

  def test_gallery_needs_alt_and_tight_list
    out, st = check(page("[{c: gallery, name: g}]", "## G\n\n- ![](/a.png)\n\n- ![B](/b.png)\n"))
    assert_equal 1, st
    assert_includes out, "alt text"
    assert_includes out, "blank lines"
  end

  def test_split_needs_visual_and_passes_params
    FileUtils.mkdir_p(File.join(@dir, "src/_data"))
    FileUtils.cp(File.expand_path("../../docs/_data/components.yml", __dir__), File.join(@dir, "src/_data/components.yml"))
    FileUtils.mkdir_p(File.join(@dir, "src/_includes/sections"))
    File.write(File.join(@dir, "src/_includes/sections/v.html"), "<p>v</p>")
    out, = check(page("[{c: split, name: a}, {c: split, name: b, visual: v, scene: 2, ratio: '5:7'}, {c: split, name: c, side: left, visual: v}, {c: features, name: d, scene: 1}]",
                      "## A\n\nT\n\n## B\n\nT\n\n## C\n\nT\n\n## D\n\n- x\n"))
    assert_includes out, "sections[0] split: needs visual:"
    refute_match(/sections\[1\]/, out)
    assert_includes out, "split.side=\"left\""
    assert_includes out, "sections[3] features: unknown param 'scene'"
  end

  def test_split_hero_params
    out, = check("---\ntitle: A\nhero: {c: split, side: left, ratio: '2:1'}\nsections: [a]\n---\n# A\n\n## A\n\nT\n")
    assert_includes out, "hero split: needs visual:"
    assert_includes out, "hero.side=\"left\""
    assert_includes out, "hero.ratio=\"2:1\""
    out, = check("---\ntitle: A\nhero: {c: tabs}\nsections: [a]\n---\n# A\n\n## A\n\nT\n")
    assert_includes out, "hero.c must be split"
  end

  def test_bleed_values
    out, = check(page("[{name: a, bleed: true}, {name: b, bleed: full}, {c: features, name: c, bleed: wide}]",
                      "## A\n\nT\n\n## B\n\nT\n\n## C\n\n- x\n"))
    refute_match(/sections\[0\]/, out)
    assert_includes out, "sections[1].bleed must be true, false or wide"
    refute_match(/sections\[2\]/, out)
  end

  def test_quote_pricing_subscribe
    out, = check(page("[{c: quote, name: q}, {c: pricing, name: p, recommended: 3}, {c: subscribe, name: s}]",
                      "## Q\n\n> no attribution\n\n## P\n\n### One\n\n### Two\n\n## S\n\nNews.\n"),
                 "modootoday: {subscribe: {action: 'http://x'}}\n")
    assert_includes out, "attribution"
    assert_includes out, "from 1 to 2"
    assert_includes out, "https://"
  end
end
