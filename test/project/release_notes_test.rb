# frozen_string_literal: true
# script/release-notes prints one CHANGELOG entry as the GitHub Release notes.
require "minitest/autorun"
require "open3"
require "tmpdir"

class ReleaseNotesTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  def run_script(*args) = Open3.capture3(RbConfig.ruby, File.join(ROOT, "script/release-notes"), *args)

  def test_released_versions_have_notes
    %w[v1.0.0 v1.1.0].each do |tag|
      out, err, st = run_script(tag)
      assert st.success?, "#{tag}: #{err}"
      refute_match(/^## /, out, "#{tag}: notes stop before the next version heading")
      refute_match(/^\[[^\]]+\]: http/, out, "#{tag}: no link references")
      assert_match(/^### /, out)
    end
  end

  def test_entry_boundaries_and_errors
    Dir.mktmpdir do |d|
      f = File.join(d, "CHANGELOG.md")
      File.write(f, "# C\n\n## [Unreleased]\n\n## [2.1.0] - 2026-01-02\n\n### Fixed\n\n- a\n\n## [2.0.9] - 2026-01-01\n\n- b\n\n[2.1.0]: https://x\n")
      out, _, st = run_script("2.1.0", f)
      assert st.success?
      assert_equal "### Fixed\n\n- a\n", out
      assert_equal "- b\n", run_script("v2.0.9", f)[0]
      refute run_script("v9.9.9", f)[2].success?
      refute run_script("Unreleased", f)[2].success?, "empty entry fails"
    end
  end
end
