# frozen_string_literal: true
require "minitest/autorun"
require_relative "site"

# Optional sheets: list styles (hero lead class, hero checks, link chips, titled items) and full-width bands (bleed:), each linked only where used.
class ListsTest < Minitest::Test
  include LayoutSite

  PAGES = {
    "l.md" => ["title: L\nlayout: doc\nhero: {checks: true}\nsections: [plain, {c: features, name: lc}]\n",
               "# L\n\nLead text.\n\n- Fast\n- Small\n\n## Plain\n\n- [One](/one/)\n- [Two](/two/)\n\nNot chips:\n\n- [Mixed](/m/) and text\n- [B](/b/)\n\nTitled:\n\n- **Speed**: very fast\n- **Size** small\n\n## Cards\n\n- [Docs](/docs/)\n- [Blog](/blog/)\n"],
    "p.md" => ["title: P\nlayout: doc\n", "# P\n\nPlain page.\n"],
  }.freeze

  def test_lists_markup_and_sheet
    Dir.mktmpdir do |d|
      src, s = build_site(d, PAGES, config: "modootoday: {lists: {link_chips: true, titled_items: true}}\n")
      h = html(s, "l.md")
      assert_includes h, '<section class="mt-hero mt-hero-checks">'
      assert_includes h, '<p class="mt-hero-lead">Lead text.</p>'
      assert_equal 1, h.scan('<ul class="mt-chips">').size
      assert_includes h, '<li><strong class="mt-item-title">Speed</strong><span class="mt-item-sep">: </span>very fast</li>'
      assert_includes h, "<li><strong>Size</strong> small</li>"
      assert_match %r{href="[^"]*/assets/css/modootoday/lists\.css"}, h
      refute_includes html(s, "p.md"), "lists.css"
      css = File.read("#{s}/assets/css/modootoday/lists.css")
      assert_includes css, "mt-chips"
      assert_includes css, "--mt-ok"
      refute_includes File.read("#{s}/assets/css/modootoday.css"), "mt-chips"
      out, st = check(src, s)
      assert st.success?, out
    end
  end

  def test_off_by_default
    Dir.mktmpdir do |d|
      _, s = build_site(d, PAGES)
      h = html(s, "l.md")
      refute_includes h, "mt-chips"
      refute_includes h, "mt-item-title"
      assert_includes h, '<p class="mt-hero-lead">'
    end
  end

  BLEED = {
    "b.md" => ["title: B\nlayout: doc\nhero: {bleed: wide}\nsections: [{name: one, bleed: true}, two]\n", "# B\n\nLead.\n\n## One\n\nBand.\n\n## Two\n\nPlain.\n"],
    "p.md" => ["title: P\nlayout: doc\n", "# P\n\nPlain page.\n"],
  }.freeze

  def test_bleed_classes_and_sheet
    Dir.mktmpdir do |d|
      src, s = build_site(d, BLEED)
      h = html(s, "b.md")
      assert_includes h, '<section class="mt-hero mt-bleed mt-bleed-wide">'
      assert_match(/<section class="mt-section mt-bleed" data-section="one">\s*<h2/, h)
      assert_match(/<section class="mt-section" data-section="two">/, h)
      assert_match %r{href="[^"]*/assets/css/modootoday/bleed\.css"}, h
      refute_includes html(s, "p.md"), "bleed.css"
      css = File.read("#{s}/assets/css/modootoday/bleed.css")
      assert_includes css, "--mt-bleed-bg"
      assert_includes css, "forced-colors"
      refute_includes File.read("#{s}/assets/css/modootoday.css"), "mt-bleed"
      out, st = check(src, s)
      assert st.success?, out
    end
  end
end
