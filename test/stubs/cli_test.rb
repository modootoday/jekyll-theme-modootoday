# frozen_string_literal: true
# modootoday-stubs command line: preview by default, --write, --check, the four exit codes, --help and --json.
require_relative "stubs_case"

class StubsCliTest < StubsCase
  def test_preview_writes_nothing_and_exits_0
    file "a.md", "---\n---\n# A\n"
    o, _, code = stubs("--twins")
    assert_equal 0, code
    assert_includes o, "create a.md.txt (missing)"
    assert_includes o, "1 change(s) planned; add --write"
    refute exist?("a.md.txt")
  end

  def test_check_exits_1_on_drift_and_0_when_clean
    file "a.md", "---\n---\n# A\n"
    _, e, code = stubs("--twins", "--check")
    assert_equal 1, code
    assert_includes e, "create a.md.txt (missing)"
    refute exist?("a.md.txt")
    file "a.md.txt", "---\nlayout: twin\n---\n"
    _, e, code = stubs("--twins", "--check", "--quiet")
    assert_equal [1, "update a.md.txt (stale)\n"], [code, e]
    stubs("--twins", "--write")
    assert_equal 0, stubs("--twins", "--check")[2]
  end

  def test_usage_and_config_errors_exit_2
    assert_equal 2, stubs[2], "no kind"
    assert_equal 2, stubs("--twins", "--bogus")[2]
    assert_equal 2, stubs("--twins", "--write", "--check")[2]
    assert_equal 2, Open3.capture3(CLEAN_ENV, RbConfig.ruby, STUBS, "--twins")[2].exitstatus, "no SRC"
    _, e, code = stubs("--aliases")
    assert_equal 2, code
    assert_match(/set modootoday\.aliases/, e)
    config "modootoday: {twins: source, aliases: {md: true}}\n"
    assert_match(/not with twins: source/, stubs("--aliases")[1])
    file "_config.yml", "a: [\n"
    assert_equal 2, stubs("--twins")[2]
    FileUtils.rm(File.join(@src, "_config.yml"))
    assert_equal 2, stubs("--twins")[2]
  end

  def test_data_errors_exit_3
    file "a.md", "---\n- not a map\n---\n# A\n"
    _, e, code = stubs("--twins")
    assert_equal 3, code
    assert_match(/a\.md: front matter is not a map/, e)
  end

  def test_json_plan
    file "a.md", "---\n---\n# A\n"
    data = JSON.parse(stubs("--twins", "--json")[0])
    assert_equal({ "mode" => "preview", "kinds" => ["twins"], "changes" => [{ "path" => "a.md.txt", "action" => "create", "reason" => "missing" }] }, data)
  end

  def test_help_lists_every_option
    o, _, code = stubs("--help")
    assert_equal 0, code
    %w[--twins --aliases --write --check --no-prune --json --quiet].each { |f| assert_includes o, f }
    assert_match(/exit status: 0 .* 1 --check found drift; 2 .*\n3 data error/, o)
    assert_match(/\A\| Option \| Does \|/, stubs("--help=markdown")[0])
  end
end
