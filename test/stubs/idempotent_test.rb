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

  def test_sibling_translation_twin_follows_its_permalink
    file "guide.md", "---\n---\n# Guide\n"
    file "guide.ja.md", "---\nlang: ja\npermalink: /ja/guide/\n---\n# ガイド\n"
    o, _, code = stubs("--twins", "--write")
    assert_equal [0, "modootoday-stubs: 2 written, 0 removed"], [code, o.lines.last.chomp]
    assert_equal "---\nlayout: twin\ntwin_of: guide.ja.md\npermalink: /ja/guide/index.md\n---\n", read("guide.ja.md.txt")
    assert_equal ["modootoday-stubs: up to date\n", 0], stubs("--twins", "--write").values_at(0, 2)
  end
end
