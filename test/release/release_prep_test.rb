# frozen_string_literal: true
# script/release-prep and script/release-status: the parts that need no network or GitHub.
require "minitest/autorun"
require "open3"
require_relative "../../script/release/checks"

class ReleasePrepTest < Minitest::Test
  ROOT = Release::Changelog::ROOT
  SRC = "# C\n\n## [Unreleased]\n\n### Fixed\n\n- old\n\n## [1.0.0] - 2026-01-01\n\nVisual: none.\n\n### Fixed\n\n- a\n\n" \
        "[Unreleased]: https://github.com/o/r/compare/v1.0.0...HEAD\n[1.0.0]: https://github.com/o/r/releases/tag/v1.0.0\n"

  def run_script(name, *args) = Open3.capture2e(RbConfig.ruby, File.join(ROOT, "script", name), *args, chdir: ROOT)

  def test_release_moves_the_entry_and_the_links
    entry = "## [1.1.0] - 2026-02-01\n\nVisual: none.\n\n### Added\n\n- b\n\n"
    out = Release::Changelog.new(SRC).release("1.1.0", entry)
    repo = Release::Changelog.repo_url
    assert_includes out, "## [Unreleased]\n\n## [1.1.0] - 2026-02-01\n"
    refute_includes out, "- old"
    assert_includes out, "[Unreleased]: #{repo}/compare/v1.1.0...HEAD\n[1.1.0]: #{repo}/releases/tag/v1.1.0\n[1.0.0]: "
  end

  def test_unreleased_section_is_replaced_and_nothing_else
    log = Release::Changelog.new(SRC)
    assert_equal "## [Unreleased]\n\n### Fixed\n\n- old\n\n", log.unreleased
    assert_equal SRC.sub("### Fixed\n\n- old\n\n", ""), log.with_unreleased(Release::Changelog::EMPTY)
  end

  def test_release_prep_refuses_a_bad_or_older_version
    out, st = run_script("release-prep", "1.7")
    refute st.success?
    assert_match(/usage: script\/release-prep X\.Y\.Z/, out)
    out, st = run_script("release-prep", "0.1.0")
    refute st.success?
    assert_match(/0\.1\.0 is not newer than/, out)
  end

  def test_release_check_table_and_verdict
    runs = [Release::Checks::Run.new("ci.yml", "completed", "success", "https://x/1"),
            Release::Checks::Run.new("visual.yml", "missing", nil, nil)]
    assert runs.first.ok?
    refute runs.last.ok?
    assert_equal "| visual.yml | missing | - | - |", Release::Checks.table(runs).lines.last
    assert_equal %w[ci.yml lighthouse.yml visual.yml], Release::Checks::WORKFLOWS
  end

  def test_repository_comes_from_the_gemspec_outside_actions
    skip "GITHUB_REPOSITORY is set" if ENV["GITHUB_REPOSITORY"]
    assert_equal Release::Changelog.repo_url, "https://github.com/#{Release::Checks.repo}"
  end
end
