# frozen_string_literal: true
require "minitest/autorun"
require_relative "site"

# badge: bottom on c: features, and reveal: true on hero: or a section (CSS-only scroll reveal).
class RevealBadgeTest < Minitest::Test
  include LayoutSite

  PAGES = {
    "r.md" => ["title: R\nlayout: doc\nhero: {reveal: true}\nsections: [{c: features, name: f, badge: bottom, reveal: true}, {c: features, name: g}]\n",
               "# R\n\nLead.\n\n## F\n\n- **A** — one `status:available`\n- **B** — two\n\n## G\n\n- **C** — three\n- **D** — four\n"],
  }.freeze

  def test_classes_and_css
    Dir.mktmpdir do |d|
      src, s = build_site(d, PAGES)
      h = html(s, "r.md")
      assert_match(/<section class="mt-hero[^"]* mt-reveal"/, h)
      assert_match(/class="mt-section mt-c-features mt-reveal mt-badge-bottom" data-section="f"/, h)
      assert_includes h, 'class="mt-section mt-c-features" data-section="g"'
      css = File.read("#{s}/assets/css/modootoday.css")
      assert_match(/@supports \(animation-timeline: ?view\(\)\)/, css)
      assert_match(/prefers-reduced-motion: ?no-preference/, css)
      assert_includes File.read("#{s}/assets/css/modootoday/showcase/card.css"), ".mt-badge-bottom"
      out, st = check(src, s)
      assert st.success?, out
    end
  end

  def test_checker_rejects_bad_values
    bad = { "b.md" => ["title: B\nlayout: doc\nsections: [{c: features, name: f, badge: top, reveal: yes please}]\n", "# B\n\n## F\n\n- **A** — a\n- **B** — b\n"] }
    Dir.mktmpdir do |d|
      src, s = build_site(d, bad)
      out, st = check(src, s)
      refute st.success?
      assert_includes out, "badge=\"top\" not in"
      assert_includes out, "reveal must be true or false"
    end
  end
end
