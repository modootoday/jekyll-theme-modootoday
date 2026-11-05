# frozen_string_literal: true
# Static math (modootoday.math.mode: static): the n-th math block becomes the n-th _data/math entry in every kramdown shape,
# translations share the file, no loader runs, and math.base derives the client loader's paths.
require "minitest/autorun"
require_relative "../../support/layout_site"

class MathStaticTest < Minitest::Test
  include LayoutSite

  FIXTURE = File.join(LayoutSite::ROOT, "test/fixtures/sites/math")
  CLIENT = "modootoday:\n  math: {mode: client, enabled: true, base: /assets/vendor/katex/, css: null}\n"
  REGION = %r{<figure class="mt-figure mt-math"><div class="mt-figure-scroll" tabindex="0" role="region" aria-label="([^"]*)"><math display="block"><mtext>(\w+)</mtext></math></div></figure>}

  def self.sites = (@sites ||= {})

  def site(name, config = "")
    self.class.sites[name] ||= begin
      dir = Dir.mktmpdir
      Minitest.after_run { FileUtils.rm_rf(dir) }
      build_site(dir, {}, config: config, from: FIXTURE).last
    end
  end

  def read(s, rel) = File.read(File.join(s, rel))

  def test_each_block_shape_takes_its_entry_in_order
    h = read(site(:static), "guide/eq/index.html")
    assert_equal [["Formula 1", "one"], ["Formula 2", "two"], ["Formula 3", "three"], ["Formula 4", "four"], ["Formula 5", "five"]], h.scan(REGION)
    assert_includes h, "\\[\\gamma\\]", "a block without an entry stays TeX"
    assert_includes h, "<code class=\"language-plaintext highlighter-rouge\">\\[</code> stays", "an inline \\[ is not a block"
    refute_match(/language-math|E = mc\^2|\\alpha|\\beta/, h)
    assert_match %r{href="[^"]*/assets/css/modootoday/media/figure\.css}, h
    refute_includes h, "modootoday-math.js"
    refute_includes h, "katex.min.css", "MathML needs no stylesheet"
  end

  def test_the_region_padding_lives_in_the_figure_sheet_only
    s = site(:static)
    assert_match(/\.mt-math ?> ?\.mt-figure-scroll ?\{ ?padding-block: ?0?\.5em;? ?\}/, read(s, "assets/css/modootoday/media/figure.css").gsub(/\s+/, " "))
    refute_includes read(s, "assets/css/modootoday.css"), ".mt-math"
  end

  def test_a_translation_reads_its_source_file
    h = read(site(:static), "ko/guide/eq/index.html")
    assert_equal [["수식 1", "one"]], h.scan(REGION)
  end

  def test_katex_html_links_the_stylesheet_and_math_false_opts_out
    s = site(:static)
    h = read(s, "other/index.html")
    assert_includes h, %(<figure class="mt-figure mt-math"><div class="mt-figure-scroll" tabindex="0" role="region" aria-label="Formula 1"><span class="katex"><span class="katex-html")
    assert_match %r{<link rel="stylesheet" href="[^"]*/assets/katex/katex\.min\.css">}, h
    off = read(s, "off/index.html")
    refute_includes off, "mt-math"
    refute_includes off, "katex.min.css"
    assert_includes off, "language-math"
  end

  def test_pages_without_math_and_the_client_mode_keep_their_output
    assert_equal read(site(:client, CLIENT), "plain/index.html"), read(site(:static), "plain/index.html")
    refute_includes read(site(:static), "plain/index.html"), "figure.css"
  end

  def test_base_derives_the_three_client_paths
    h = read(site(:client, CLIENT), "guide/eq/index.html")
    refute_includes h, "mt-math"
    assert_match %r{<link rel="stylesheet" href="[^"]*/assets/vendor/katex/katex\.min\.css">}, h
    assert_match %r{<script src="[^"]*/assets/vendor/katex/katex\.min\.js" defer></script>}, h
    assert_match %r{<script src="[^"]*/assets/vendor/katex/contrib/auto-render\.min\.js" defer></script>}, h
    assert_match(/modootoday-math\.js(\?v=[^"]*)?" data-mt-inline="false" defer/, h)
  end
end
