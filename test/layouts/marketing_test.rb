# frozen_string_literal: true
# Marketing layouts: own bundle, pricing reuses the component sheet with a CSS-only switch, CSP-safe swatches,
# ProfilePage / ContactPage structured data, checker contract.
require "minitest/autorun"
require_relative "site"

class MarketingLayoutsTest < Minitest::Test
  include LayoutSite

  PLANS = "plans:\n  - {name: Free, monthly: 0, yearly: 0, features: [One site]}\n  - {name: Team, monthly: 12, yearly: 120, recommended: true, cta: {label: Buy, url: /buy/}}\n"
  PAGES = {
    "f.md" => "title: F\nlayout: feature\nfeatures: [{title: Fast, text: Quick.}]\ncta: {label: Go, url: /go/}\n",
    "pr.md" => "title: P\nlayout: pricing\ncurrency: $\n#{PLANS}",
    "d.md" => "title: D\nlayout: download\nversion: 1.0.0\ndownloads: [{label: macOS, url: /m.dmg, size: 9 MB}]\n",
    "b.md" => "title: B\nlayout: brand\ncolors: [{name: Ink, hex: '#111111'}]\nassets: [{label: Logo, url: /l.svg, format: SVG}]\n",
    "l.md" => "title: L\nlayout: links\nname: Ada\nlinks: [{label: GitHub, url: 'https://github.com/ada'}, {label: Blog, url: /blog/}]\n",
    "c.md" => "title: C\nlayout: contact\ncontacts: [{label: Email, value: a@example.com, url: 'mailto:a@example.com'}]\nform: {action: 'https://forms.example.com/x'}\n",
  }.freeze

  def test_build
    Dir.mktmpdir do |d|
      src, s = build_site(d, PAGES)
      PAGES.each_key { |n| assert_includes html(s, n), "modootoday-marketing.css", n }
      p = html(s, "pr.md")
      assert_match(%r{href="[^"]*/pricing\.css"}, p)
      assert_includes p, 'id="mt-bill-y"'
      assert_includes p, '<label for="mt-bill-m">'
      refute_match(/style="/, html(s, "b.md"))
      assert_includes html(s, "b.md"), 'fill="#111111"'
      refute_includes html(s, "l.md"), 'class="mt-header"'
      lp = graph(s, "l.md").find { |n| n["@type"] == "ProfilePage" }
      assert_equal ["Person", ["https://github.com/ada"]], [lp["mainEntity"]["@type"], lp["mainEntity"]["sameAs"]]
      assert graph(s, "c.md").any? { |n| n["@type"] == "ContactPage" }
      assert_includes html(s, "c.md"), '<label for="mt-f-email">'
      out, st = check(src, s)
      assert st.success?, out
    end
  end

  def test_checker_contracts
    Dir.mktmpdir do |d|
      bad = { "p.md" => "title: P\nlayout: pricing\nplans: [{name: A, monthly: 1, yearly: 10}, {name: B}]\n",
              "b.md" => "title: B\nlayout: brand\ncolors: [{name: X, hex: red}]\n",
              "c.md" => "title: C\nlayout: contact\nform: {action: 'http://x', fields: [phone]}\n" }
      src, s = build_site(d, bad)
      out, st = check(src, s)
      refute st.success?
      ["plans[1].monthly is required", "set yearly on every plan", "hex must be", "form must be a map"].each { |m| assert_includes out, m }
    end
  end
end
