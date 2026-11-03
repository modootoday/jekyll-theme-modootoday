# frozen_string_literal: true
# filter: on a sections: item or a page without sections, and filter_text: on a directory: the data-mt-filter root, the
# hidden controls, the filter sheet and the module script, and that pages without them get none of it.
require "minitest/autorun"
require_relative "../../support/layout_site"

class FilterTest < Minitest::Test
  include LayoutSite

  TABLE = "| Tool | Kind |\n|---|---|\n| Rank | Free |\n| Volume | Paid |\n"
  PAGES = {
    "f/page.md" => ["title: P\nfilter: true\n", "# P\n\n- One\n- Two\n"],
    "f/sections.md" => ["title: S\nsections: [{name: a, filter: {facet: 2}}, b]\n", "# S\n\nLead.\n\n## A\n\n#{TABLE}\n## B\n\n- x\n"],
    "f/plain.md" => ["title: N\n", "# N\n\n- One\n- Two\n"],
    "f/dir.md" => ["title: D\nlayout: directory\nfilter_text: true\nitems: [{title: Alpha}, {title: Beta}]\n", "Intro.\n"],
  }.freeze
  CONTROLS = '<div class="mt-filter" hidden><input type="search" aria-label="Filter" placeholder="Filter">' \
             '<output aria-live="polite" data-count="[n] shown"></output></div>'

  def built
    self.class.instance_variable_get(:@built) || self.class.instance_variable_set(:@built, begin
      d = Dir.mktmpdir
      Minitest.after_run { FileUtils.rm_rf(d) }
      build_site(d, PAGES, config: "modootoday: {components: [callout]}\n")[1]
    end)
  end

  def head(name) = html(built, name)[%r{<head>.*</head>}m]
  def main(name) = html(built, name)[%r{<main.*</main>}m]

  def test_page_filter_marks_the_prose_and_adds_the_controls
    m = main("f/page.md")
    assert_includes m, '<div class="mt-prose" data-mt-filter>'
    assert_match(/<\/ul>\s*#{Regexp.escape(CONTROLS)}\n<\/div>/, m)
  end

  def test_section_filter_with_a_facet
    m = main("f/sections.md")
    assert_match %r{<section class="mt-section" data-section="a" data-mt-filter data-facet="2">}, m
    assert_equal 1, m.scan(CONTROLS).size
    assert_includes m, '<section class="mt-section" data-section="b">'
  end

  def test_directory_filter_text
    m = main("f/dir.md")
    assert_includes m, '<div class="mt-dir mt-dir-cards" data-mt-filter>'
    assert_includes m, CONTROLS
  end

  def test_sheet_and_module_only_where_used
    %w[f/page.md f/sections.md f/dir.md].each do |p|
      h = head(p) + html(built, p)
      assert_match %r{<link rel="stylesheet" href="/assets/css/modootoday/filter\.css\?v=[^"]+">}, h, p
      assert_match %r{<script type="module" src="/assets/js/modootoday/filter/filter\.js\?v=[^"]+"></script>}, h, p
    end
    plain = html(built, "f/plain.md")
    refute_includes plain, "filter.css"
    refute_includes plain, "filter.js"
    refute_includes plain, "data-mt-filter"
  end
end
