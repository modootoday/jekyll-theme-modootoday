# frozen_string_literal: true
# Static math (page/figures/math_static.rb): blocks against _data/math entries, inline math, the key rule and the
# modootoday-check SRC --math list, on the m03 corpus fixtures. Run: bundle exec rake test
require "json"
require_relative "../../checker_case"
require_relative "../../../../lib/modootoday/figures"
require_relative "../../../../lib/modootoday/i18n/page_lang"

class CheckMathStaticTest < CheckerCase
  MD = File.expand_path("../../../fixtures/md", __dir__)
  F = Modootoday::Figures
  STATIC = "modootoday:\n  languages: [en, ko]\n  math: {mode: static}\n"

  def setup
    super
    page "_config.yml", STATIC
  end

  def fixture(name, rel = "guide/a.md", fm = "") = page(rel, "---\n#{fm}---\n" + File.read(File.join(MD, "#{name}.md")))

  def data(key, tex, html: "<math></math>")
    page "_data/math/#{key}.yml", tex.map { |t| "- src: #{F.digest(t).to_json}\n  html: #{html.to_json}\n" }.join
  end

  def list
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, @src, "--math")
    [JSON.parse(o), e, st.exitstatus]
  end

  def test_the_block_shapes_in_order
    blocks = F.math_blocks(File.read(File.join(MD, "m03-math-static-ok.md")))
    assert_equal ["x^2\n", "E = mc^2", "a < b", "\\alpha", "\\beta"], blocks.map { |b| b[:body] }
    assert_equal [[3, 5], [7, 9], [11, 11], [15, 17], [19, 21]], blocks.map { |b| [b[:line], b[:last]] }
  end

  def test_the_key_is_the_source_path
    pl = Modootoday::I18n::PageLang.new(%w[ko vi], "en")
    { "guide/a.md" => "guide--a", "guide/a.ko.md" => "guide--a", "ko/guide/a.md" => "guide--a", "home/index.vi.md" => "index", "a.b.md" => "a.b" }
      .each { |rel, key| assert_equal key, F.math_key(rel, pl), rel }
    assert_equal "mine", F.math_key("guide/a.md", pl, { "math_key" => "mine" })
  end

  def test_matching_entries_pass_and_translations_share_them
    fixture "m03-math-static-ok"
    fixture "m03-math-static-ok", "guide/a.ko.md", "lang: ko\npermalink: /ko/guide/a/\n"
    data "guide--a", ["x^2", "E = mc^2", "a < b", "\\alpha", "\\beta"]
    o, code = check
    assert_equal 0, code, o
    assert_equal [[], 0], list.values_at(0, 2)
  end

  def test_missing_stale_and_counted
    fixture "m03-math-static-ok"
    o, code = check
    assert_equal 1, code
    assert_includes o, "guide/a.md: 5 math blocks but no _data/math/guide--a.yml; render them again (modootoday-check SRC --math lists them)"
    data "guide--a", ["x^2", "E = mc^3", "a < b", "\\alpha"]
    o, = check
    assert_includes o, "guide/a.md: _data/math/guide--a.yml has 4 entries but the page has 5 math blocks (lines 5, 9, 13, 17, 21); the n-th block is the n-th entry"
    assert_includes o, "guide/a.md:9: stale math: entry 2 of _data/math/guide--a.yml was rendered from other TeX than this block (#{F.digest('E = mc^2')})"
  end

  def test_inline_math_is_an_error_in_static_mode
    fixture "m03-math-static-inline"
    data "guide--a", ["E = mc^2"]
    o, = check
    assert_includes o, "guide/a.md:9: inline math cannot be rendered ahead of time (modootoday.math.mode: static); make it a $$ block"
    fixture "m03-math-static-count"
    data "guide--a", ["x^2", "z^2"]
    o, = check
    assert_includes o, "guide/a.md:9: inline math cannot be rendered ahead of time"
    refute_match(/has \d entries but/, o, "$$…$$ inside a sentence is not a block")
  end

  def test_the_list_names_the_source_page_and_its_blocks
    fixture "m03-math-static-ok", "guide/a.ko.md", "lang: ko\npermalink: /ko/guide/a/\n"
    fixture "m03-math-static-ok"
    items, err, code = list
    assert_equal 1, code
    assert_empty err
    assert_equal 1, items.size
    item = items.first
    assert_equal %w[key file page blocks reason], item.keys
    assert_equal ["guide--a", "_data/math/guide--a.yml", "guide/a.md", "missing"], item.values_at("key", "file", "page", "reason")
    assert_equal({ "line" => 5, "tex" => "x^2", "digest" => F.digest("x^2") }, item["blocks"].first)
  end

  def test_katex_html_needs_its_stylesheet_and_math_false_skips_a_page
    fixture "m03-math-static-count", "b.md", "math_key: b\n"
    fixture "m03-math-static-inline", "off.md", "math: false\n"
    data "b", ["x^2", "z^2"], html: '<span class="katex"><span class="katex-html">x</span></span>'
    o, = check
    assert_includes o, "b.md: _data/math/b.yml holds KaTeX HTML output, which needs KaTeX's stylesheet"
    refute_includes o, "off.md"
    page "_config.yml", "modootoday:\n  math: {mode: static, base: /assets/katex/}\n"
    o, = check
    refute_includes o, "KaTeX HTML"
  end

  def test_client_mode_lists_nothing
    page "_config.yml", "modootoday:\n  math: {enabled: true, src: /k.js, css: /k.css}\n"
    fixture "m03-math-static-ok"
    assert_equal [[], 0], list.values_at(0, 2)
    o, = check
    refute_includes o, "_data/math"
  end
end
