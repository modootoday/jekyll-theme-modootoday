# frozen_string_literal: true
# CHANGELOG.md keeps the Keep a Changelog shape, and a released entry never changes after its tag.
# Cited spec ids are resolved by spec_ids_test.rb, which covers this file with every other one.
require "minitest/autorun"
require "date"
require "open3"
require_relative "../../script/release/changelog"

class ChangelogTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  REPO = "https://github.com/modootoday/jekyll-theme-modootoday"
  SECTIONS = %w[Added Changed Deprecated Removed Fixed Security].freeze
  # Entries released before this lint, kept as tagged: released entries are immutable.
  PAST_SECTIONS = {
    "1.0.0" => ["Added", "Fixed", "Changed", "Pre-release history"],
    "1.1.0" => %w[Added Documentation],
    "1.2.3" => %w[Changed Fixed Documentation],
  }.freeze
  PAST_EDITS = { "1.0.0" => "tagged with an undated heading; the date and the publish note came after the tag" }.freeze
  VISUAL_SINCE = Gem::Version.new("1.5.0") # the first entry that opens with a Visual: line
  LOCAL = [%r{(?:^|[\s`'"(=])/(?:home|tmp|Users|root|private|var/folders)/}, /\.spec\.local/, %r{file://}, /\b[A-Z]:\\/,
           /[\w.+-]+@[\w-]+(?:\.[a-z]{2,})+\b/].freeze

  def source = @source ||= File.read(File.join(ROOT, "CHANGELOG.md"))

  # Version => entry text (heading included), in file order; link definitions end the last entry.
  def self.entries(src)
    body = src[/\A.*?(?=^\[[^\]]+\]: https?:)/m] || src
    body.split(/^(?=## \[)/).drop(1).to_h { |e| [e[/\A## \[([^\]]+)\]/, 1], e] }
  end

  def entries = @entries ||= self.class.entries(source)
  def released = entries.reject { |v, _| v == "Unreleased" }
  def sections(entry) = entry.scan(/^### (.+)$/).flatten

  def test_header_and_unreleased_first
    assert source.start_with?("# Changelog\n"), "title"
    assert_includes source, "https://keepachangelog.com/en/1.1.0/"
    assert_equal "Unreleased", entries.keys.first
    assert_match(/\A## \[Unreleased\]\n/, entries["Unreleased"], "no date on Unreleased")
  end

  def test_sections_are_keep_a_changelog_in_order
    entries.each do |v, e|
      got = sections(e)
      next assert_equal(PAST_SECTIONS[v], got, "#{v}: released entries keep their tagged sections") if PAST_SECTIONS.key?(v)

      assert_empty got - SECTIONS, "#{v}: sections are #{SECTIONS.join(", ")}"
      assert_equal SECTIONS & got, got, "#{v}: sections in the order #{SECTIONS.join(", ")}"
      assert_equal got.uniq, got, "#{v}: one heading per section"
    end
  end

  def test_released_headings_are_dated_and_newest_first
    released.each do |v, e|
      assert_match(/\A\d+\.\d+\.\d+\z/, v)
      date = e[/\A## \[[^\]]+\] - (\d{4}-\d{2}-\d{2})\n/, 1]
      assert date && Date.iso8601(date), "#{v}: heading is ## [#{v}] - YYYY-MM-DD"
    end
    versions = released.keys.map { |v| Gem::Version.new(v) }
    assert_equal versions.sort.reverse, versions, "newest version first"
    dates = released.values.map { |e| e[/ - (\S+)\n/, 1] }
    assert_equal dates.sort.reverse, dates, "dates never go forward down the file"
  end

  def test_link_definitions_compare_unreleased_and_tag_each_version
    want = { "Unreleased" => "#{REPO}/compare/v#{released.keys.first}...HEAD" }
    released.each_key { |v| want[v] = "#{REPO}/releases/tag/v#{v}" }
    assert_equal want.to_a, source.scan(/^\[([^\]]+)\]: (\S+)$/)
  end

  def test_released_entries_from_the_first_visual_one_open_with_a_visual_line
    newer = released.select { |v, _| Gem::Version.new(v) >= VISUAL_SINCE }
    refute_empty newer
    newer.each { |v, e| assert_match(/\A## [^\n]+\n\nVisual: \S/, e, "#{v}: open the entry with `Visual: `") }
  end

  # [Unreleased] is git-cliff's render of the commits since the last tag (adr:modootoday/20261109225758).
  def test_unreleased_is_generated_from_the_commits
    skip "git-cliff is not installed (npm ci); push CI runs script/changelog --check" unless Release::Changelog.cliff
    log = Release::Changelog.new(source)
    assert_equal log.expected_unreleased, log.unreleased, "run ruby script/changelog (or bundle exec rake fix), then amend"
  rescue Release::Error => e
    skip e.message
  end

  def test_released_entries_keep_no_release_prep_placeholder
    released.each { |v, e| refute_includes e, "<!-- release-prep:", "#{v}: write the Visual line and the summary" }
  end

  def test_no_local_paths_or_addresses
    LOCAL.each { |re| refute_match re, source }
  end

  def test_released_entries_match_their_tags
    tags = Open3.capture2("git", "tag", "--list", "v*", chdir: ROOT).first.split
    skip "no release tags in this checkout (a shallow clone)" if tags.empty?
    compared = released.keys.select { |v| tags.include?("v#{v}") } - PAST_EDITS.keys
    compared.each do |v|
      tagged, st = Open3.capture2("git", "show", "v#{v}:CHANGELOG.md", chdir: ROOT)
      next unless st.success?

      assert_equal self.class.entries(tagged)[v], released[v], "#{v}: a released entry is never edited; add to [Unreleased]"
    end
    stale = PAST_EDITS.keys.select { |v| tags.include?("v#{v}") && self.class.entries(`git -C #{ROOT} show v#{v}:CHANGELOG.md`)[v] == released[v] }
    assert_empty stale, "matches its tag again: remove from PAST_EDITS"
  end

  def test_parser_splits_entries_and_stops_at_links
    src = "# C\n\n## [Unreleased]\n\n## [2.0.0] - 2026-01-02\n\n### Fixed\n\n- a\n\n[Unreleased]: https://x\n"
    got = self.class.entries(src)
    assert_equal %w[Unreleased 2.0.0], got.keys
    assert_equal "## [2.0.0] - 2026-01-02\n\n### Fixed\n\n- a\n\n", got["2.0.0"]
  end
end
