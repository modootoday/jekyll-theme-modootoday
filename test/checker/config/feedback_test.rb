# frozen_string_literal: true
# modootoday.feedback (lib/modootoday/check/config/keys/pages/feedback.rb) and the site.github warning it shares.
require_relative "../checker_case"

class CheckFeedbackConfigTest < CheckerCase
  def config(text)
    page "_config.yml", "modootoday:\n  feedback: #{text}\n"
    page "index.md", "---\n---\n# Home\n"
    check[0]
  end

  def test_a_valid_map_passes
    o = config("{issues: https://github.com/o/r/issues, helpful: true, discuss: https://github.com/o/r/discussions, labels: [docs-feedback]}")
    refute_match(/feedback/, o)
  end

  def test_bad_values_name_the_sub_key
    o = config("{issues: https://github.com/o/r, helpful: maybe, discuss: forum, labels: docs}")
    assert_includes o, "modootoday.feedback.issues must be auto, false or a repository's issues URL"
    assert_includes o, "modootoday.feedback.helpful must be true or false"
    assert_includes o, "modootoday.feedback.discuss must be an http(s) URL"
    assert_includes o, "modootoday.feedback.labels must be a list of label names"
  end

  def test_auto_without_site_github_and_helpful_without_issues_warn
    assert_includes config("{issues: auto}"), "modootoday.feedback.issues: \"auto\" reads site.github"
    assert_includes config("{helpful: true}"), "modootoday.feedback.helpful: true needs issues:"
  end

  def test_an_unknown_key_is_refused
    assert_includes config("{issue: auto}"), "modootoday.feedback must be a map of issues, helpful, discuss and labels"
  end
end
