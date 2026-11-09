# frozen_string_literal: true
# cliff.toml maps commit types and footers to the Keep a Changelog sections that test/project/changelog_test.rb expects.
require "minitest/autorun"
require "open3"
require "tmpdir"
require_relative "../../script/release/changelog"

class CliffTest < Minitest::Test
  ROOT = Release::Changelog::ROOT
  ENV_GIT = { "GIT_AUTHOR_NAME" => "t", "GIT_AUTHOR_EMAIL" => "t@localhost", "GIT_COMMITTER_NAME" => "t",
              "GIT_COMMITTER_EMAIL" => "t@localhost", "GIT_CONFIG_GLOBAL" => File::NULL, "GIT_CONFIG_NOSYSTEM" => "1" }.freeze

  def setup
    @bin = Release::Changelog.cliff or skip "git-cliff is not installed (npm ci)"
  end

  # Renders the commits made after a v1.0.0 tag in a scratch repository.
  def render(*messages, tag: nil)
    Dir.mktmpdir do |d|
      git(d, "init", "-q", "-b", "main")
      git(d, "commit", "-q", "--allow-empty", "-m", "chore: start")
      git(d, "tag", "v1.0.0")
      messages.each { |m| git(d, "commit", "-q", "--allow-empty", "-m", m) }
      args = [@bin, "--config", File.join(ROOT, "cliff.toml"), "--workdir", d, "--unreleased"] + (tag ? ["--tag", tag] : [])
      out, err, st = Open3.capture3(ENV_GIT, *args)
      assert st.success?, err
      out.strip
    end
  end

  def git(dir, *args)
    _, err, st = Open3.capture3(ENV_GIT, "git", "-C", dir, *args)
    assert st.success?, err
  end

  def test_types_go_to_their_sections_in_keep_a_changelog_order
    out = render("fix: a crash", "feat(blog): a list", "perf: faster pages", "fix(security): escape a title",
                 "feat: the x key\n\nDeprecated: The x key is deprecated; use y")
    assert_equal ["Added", "Changed", "Deprecated", "Fixed", "Security"], out.scan(/^### (.+)$/).flatten
    assert_includes out, "### Added\n\n- A list\n"
    assert_includes out, "### Deprecated\n\n- The x key is deprecated; use y\n"
    assert_includes out, "### Fixed\n\n- A crash\n"
  end

  def test_internal_commits_are_skipped_unless_a_changelog_footer_says_otherwise
    out = render("chore: tidy", "ci: cache", "test: more", "docs(spec): an adr", "refactor: move",
                 "test(changelog): a lint\n\nChangelog: For contributors: a CHANGELOG lint")
    assert_equal "## [Unreleased]\n\n### Changed\n\n- For contributors: a CHANGELOG lint", out
  end

  def test_changelog_none_drops_even_a_feature
    assert_equal "## [Unreleased]", render("feat: hidden\n\nChangelog: none")
  end

  def test_breaking_refs_migration_and_visual_footers
    out = render("feat!: drop the old menu\n\nRefs: adr:modootoday/1\nMigration: use nav instead",
                 "chore: shots\n\nVisual: the header is taller.")
    assert_match(/\A## \[Unreleased\]\n\nVisual: the header is taller\.\n\n### Changed\n/, out)
    assert_includes out, "- **Breaking:** Drop the old menu (adr:modootoday/1) Upgrade: use nav instead"
  end

  def test_a_release_entry_has_a_date_and_the_hand_written_placeholders
    out = render("fix: a crash", tag: "v1.1.0")
    assert_match(/\A## \[1\.1\.0\] - \d{4}-\d{2}-\d{2}\n\nVisual: <!-- release-prep:/, out)
    assert_equal 2, out.scan(Release::Changelog::PLACEHOLDER).size
  end
end
