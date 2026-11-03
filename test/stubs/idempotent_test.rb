# frozen_string_literal: true
# modootoday-stubs is idempotent: a second --write changes nothing, and files already right keep their mtime.
require_relative "stubs_case"

class StubsIdempotentTest < StubsCase
  def test_second_run_changes_nothing
    config "modootoday: {aliases: {md: true, html: true}}\n"
    file "index.md", "---\n---\n# Home\n"
    file "ko/guide.md", "---\nlang: ko\n---\n# Guide\n"
    o, _, code = stubs("--twins", "--aliases", "--write")
    assert_equal 0, code
    assert_match(/4 written, 0 removed/, o)
    stamp = File.join(@src, "ko/guide.md.txt")
    File.utime(Time.at(0), Time.at(0), stamp)
    before = Dir.glob("**/*", base: @src).sort.to_h { |f| [f, File.file?(File.join(@src, f)) && read(f)] }
    o, _, code = stubs("--twins", "--aliases", "--write")
    assert_equal [0, "modootoday-stubs: up to date\n"], [code, o]
    assert_equal before, Dir.glob("**/*", base: @src).sort.to_h { |f| [f, File.file?(File.join(@src, f)) && read(f)] }
    assert_equal Time.at(0), File.mtime(stamp)
    assert_equal [0], stubs("--twins", "--aliases", "--check").values_at(2)
  end
end
