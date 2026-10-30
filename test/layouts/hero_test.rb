# frozen_string_literal: true
# Hero visual "showcase": own bundle only where used, responsive LCP image, decorative SVG pair, user image, checker.
require "minitest/autorun"
require_relative "site"

class HeroShowcaseTest < Minitest::Test
  include LayoutSite

  BODY = "# Title\n\nLead text.\n\n## One\n\nText.\n"
  PAGES = {
    "h.md" => ["title: H\nhero: {visual: showcase}\nsections: [one]\n", BODY],
    "u.md" => ["title: U\nhero: {visual: showcase, image: /u.webp, width: 800, height: 600}\nsections: [one]\n", BODY],
    "p.md" => ["title: P\nsections: [one]\n", BODY],
  }.freeze

  def test_build
    Dir.mktmpdir do |d|
      src, s = build_site(d, PAGES)
      h = html(s, "h.md")
      assert_includes h, "modootoday-hero.css"
      refute_includes html(s, "p.md"), "modootoday-hero.css"
      assert_match(/<div class="mt-showcase" aria-hidden="true">/, h)
      assert_match(/dawn-640\.webp 640w, .*dawn-1280\.webp 1280w/, h)
      assert_includes h, 'fetchpriority="high"'
      refute_match(/mt-showcase-bg[^>]*loading="lazy"/, h)
      assert_includes h, 'class="mt-showcase-motion"'
      assert_includes h, 'class="mt-showcase-still"'
      still = h[%r{<svg class="mt-showcase-still".*?</svg>}m]
      refute_match(/<animate|<set /, still)
      refute_match(/repeatCount="indefinite"/, h)
      assert_includes h, '<h1 id="title">Title</h1>'
      u = html(s, "u.md")
      assert_match(%r{src="[^"]*/u\.webp"[^>]*width="800" height="600"}, u)
      refute_includes u, "dawn-640"
      o, = check(src, s)
      refute_includes o, "visual: _includes/sections/showcase.html not found"
    end
  end

  def test_assets_ship
    %w[640 960 1280].each { |w| assert_operator File.size("#{ROOT}/assets/modootoday/hero/dawn-#{w}.webp"), :<, 150 * 1024 }
  end
end
