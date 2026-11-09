# frozen_string_literal: true
# script/commit-check: the commit rules the generated CHANGELOG relies on.
require "minitest/autorun"
require "open3"
require_relative "../../script/release/commit_check"

class CommitCheckTest < Minitest::Test
  ROOT = Release::CommitCheck::ROOT

  def check(message, files = ["_includes/modootoday/x.html"]) = Release::CommitCheck.new.problems(message, files)

  def test_shipped_paths_come_from_the_gemspec
    assert_equal %w[_includes _layouts _sass assets exe i18n lib], Release::CommitCheck.shipped.sort
  end

  def test_listed_types_on_shipped_paths_pass
    ["feat: a list", "fix(blog): a crash", "perf: faster", "docs: a page", "refactor!: rename a key"].each do |m|
      assert_empty check(m), m
    end
  end

  def test_shipped_paths_need_a_conventional_subject
    assert_match(/Conventional Commit/, check("Add a list").first)
    assert_match(/Conventional Commit/, check("feature: a list").first)
    assert_empty check("Add a list", ["docs/index.md"]), "only shipped paths are checked"
  end

  def test_a_skipped_type_on_shipped_paths_needs_a_changelog_footer
    assert_match(/Changelog: none/, check("refactor(lib): split a file").first)
    assert_match(/Changelog: none/, check("docs(spec): an adr").first)
    assert_empty check("refactor(lib): split a file\n\nChangelog: none")
    assert_empty check("chore: rename\n\nChangelog: The x include is renamed y.\nRefs: adr:modootoday/20261109225758")
    assert_empty check("chore: drop\n\nRemoved: The x include.")
    assert_empty check("test: more", ["test/a_test.rb"])
  end

  def test_footers_are_well_formed
    assert_equal ["Changelog: footer is empty"], check("feat: a\n\nChangelog: ")
    assert_match(/not a spec id/, check("feat: a\n\nRefs: ADR-12").first)
    assert_empty check("feat: a\n\nRefs: adr:modootoday/1, audit:modootoday/2")
  end

  def test_footers_parse_the_last_paragraph_with_continuation_lines
    msg = "feat: a\n\nBody text: not a footer here.\n\nChangelog: one\n  two\nCo-Authored-By: A <a@localhost>\n"
    assert_equal [["Changelog", "one two"], ["Co-Authored-By", "A <a@localhost>"]], Release::CommitCheck.footers(msg)
    assert_empty Release::CommitCheck.footers("feat: a\n\nplain body")
  end

  def test_the_command_checks_a_range
    out, st = Open3.capture2e(RbConfig.ruby, File.join(ROOT, "script/commit-check"), "-1", "HEAD", chdir: ROOT)
    assert st.success?, out
    assert_match(/\Acommit-check: [01] commits ok/, out)
  end
end
