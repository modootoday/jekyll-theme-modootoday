# frozen_string_literal: true
# Directory layouts: presets inherit the engine, own bundle, CSS-only filter, accessible cards.
require "minitest/autorun"

class DirectoryLayoutsTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  PRESETS = { "portfolio" => "tags", "team" => "group", "jobs" => "department", "events" => nil, "sponsors" => "tier", "integrations" => "category" }.freeze

  def read(f) = File.read(File.join(ROOT, f))

  def test_presets_extend_the_engine
    PRESETS.each do |l, f|
      src = read("_layouts/#{l}.html")
      assert_match(/^layout: directory$/, src)
      assert_match(/^mt_preset: #{l}$/, src)
      f ? assert_match(/^mt_filter: #{f}$/, src) : refute_match(/mt_filter/, src)
    end
    assert_match(/^mt_bundle: directory$/, read("_layouts/directory.html"))
    assert File.exist?(File.join(ROOT, "assets/css/modootoday-directory.scss"))
  end

  def test_no_new_script
    (PRESETS.keys + ["directory"]).map { |l| "_layouts/#{l}.html" }.concat(Dir.glob("_includes/modootoday/directory/*.html", base: ROOT)).each do |f|
      refute_match(/<script(?! type="application\/ld\+json")/, read(f), "#{f}: no new JavaScript")
    end
  end

  def test_filter_is_a_labelled_radio_group
    src = read("_includes/modootoday/directory/filter.html")
    assert_includes src, "<fieldset"
    assert_includes src, "<legend"
    assert_includes src, 'type="radio"'
    assert_match(/@for \$i from 1 through 12/, read("_sass/modootoday/directory/_filter.scss"))
  end

  def test_calendar_link_names_the_event
    assert_includes read("_includes/modootoday/directory/ics.html"), '<span class="mt-sr-only">: {{ include.title }}</span>'
  end
end
