# frozen_string_literal: true
# modootoday-check command line: usage, --help, --strict and the OK summary. Run: bundle exec rake test
require_relative "checker_case"

class CheckCliTest < CheckerCase
  def test_ok_page
    page "a.md", "---\ntitle: A\n---\n# A\n\n> [!NOTE]\n> hi\n"
    o, code = check
    assert_equal 0, code, o
    assert_match(/OK \(1 pages\)/, o)
  end

  def test_strict_turns_warnings_into_errors
    page "a.md", "---\n---\n> [! NOTE]\n> x\n"
    o, code = check
    assert_equal 0, code, o
    assert_match(/warning: .*with a space is not an alert/, o)
    assert_equal 1, check("--strict")[1]
  end

  def test_usage
    _, _, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK)
    refute st.success?
    o, st = Open3.capture2(CLEAN_ENV, RbConfig.ruby, CHECK, "--help")
    assert st.success?
    assert_match(/usage: modootoday-check/, o)
  end

  def test_a_source_without_a_site_gets_the_build_step
    _, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, ".")
    assert_equal 1, st.exitstatus
    assert_includes e, "SITE is missing"
    assert_includes e, "bundle exec jekyll build && bundle exec modootoday-check . _site"
    assert_includes e, "usage: modootoday-check SRC SITE"
  end
end
