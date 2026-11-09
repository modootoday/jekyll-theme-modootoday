# frozen_string_literal: true
require "minitest/autorun"
require_relative "../../support/layout_site"

# SVG figures: labelled focusable scroll region and the optional figure sheet, only where an SVG figure is.
class FigureSvgTest < Minitest::Test
  include LayoutSite

  PAGES = {
    "svg.md" => ["title: S\nlayout: doc\n", "# S\n\n![Request flow from browser to server](/assets/flow.svg)\n\n*The request flow.*\n"],
    "png.md" => ["title: P\nlayout: doc\n", "# P\n\n![A photo](/assets/photo.png)\n\n*A photo.*\n"],
  }.freeze

  def test_svg_figure_region_and_sheet
    Dir.mktmpdir do |d|
      _, s = build_site(d, PAGES)
      h = html(s, "svg.md")
      assert_includes h, %(<figure class="mt-figure mt-figure-svg"><div class="mt-figure-scroll" tabindex="0" role="region" aria-label="Diagram, The request flow."><img src="/assets/flow.svg")
      assert_match %r{href="[^"]*/assets/css/modootoday/media/figure\.css(\?v=[^"]*)?"}, h
      p = html(s, "png.md")
      assert_includes p, %(<figure class="mt-figure"><img src="/assets/photo.png")
      assert_includes p, "modootoday/media/figure.css", "a plain figure needs the figure rules too"
      refute_includes p, "mt-figure-scroll"
      css = File.read("#{s}/assets/css/modootoday/media/figure.css")
      assert_includes css, "--mt-diagram-filter-dark"
      assert_includes css, "var(--mt-img-filter-dark"
      refute_includes File.read("#{s}/assets/css/modootoday.css"), "mt-figure-svg"
    end
  end
end
