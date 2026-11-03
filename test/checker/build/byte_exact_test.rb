# frozen_string_literal: true
# --byte-exact=DIR (lib/modootoday/check/build/byte_exact.rb): same sha256 in the build, and folders or files Jekyll would not copy.
require_relative "../checker_case"

class CheckByteExactTest < CheckerCase
  def setup
    super
    write File.join(@src, "_config.yml"), "exclude: [private]\n"
    page "index.md", "---\n---\n# Home\n"
    page "api/a.json", "{\"a\":1}\n"
    page "api/v1/b.json", "[1]\n"
  end

  def errors(*dirs) = check("--byte-exact=#{dirs.join(",")}")[0].lines.grep_v(/md-components check|^warning: (?!--byte)/).join

  def test_same_bytes_pass
    out "api/a.json", "{\"a\":1}\n"
    out "api/v1/b.json", "[1]\n"
    assert_equal "", errors("api")
  end

  def test_missing_and_changed_files
    out "api/a.json", "{\"a\": 1}\n"
    o = errors("api")
    assert_match(/api\/a\.json: the built file differs from the source \(sha256 \h{12} != \h{12}\)/, o)
    assert_match(%r{api/v1/b\.json: missing from the build}, o)
  end

  def test_files_jekyll_renders_or_skips
    page "api/c.json", "---\n---\n{}\n"
    page "api/d.md", "# D\n"
    page "api/_e.json", "{}\n"
    o = errors("api")
    assert_match(%r{api/c\.json: has front matter}, o)
    assert_match(%r{api/d\.md: Jekyll converts this file type}, o)
    assert_match(%r{api/_e\.json: not published}, o)
  end

  def test_folders_that_cannot_be_byte_exact
    page "_data/x.json", "{}\n"
    page "private/y.json", "{}\n"
    o = errors("_data", "private", "nope")
    assert_match(/--byte-exact=_data: Jekyll does not publish folders/, o)
    assert_match(/--byte-exact=private: excluded in _config\.yml \(exclude: private\)/, o)
    assert_match(/--byte-exact=nope: not a folder/, o)
    assert_match(/name at least one folder/, check("--byte-exact=")[0])
  end

  def test_include_lets_a_dot_folder_through
    write File.join(@src, "_config.yml"), "include: [.well-known]\n"
    page ".well-known/security.txt", "Contact: mailto:security@example.org\n"
    out ".well-known/security.txt", "Contact: mailto:security@example.org\n"
    assert_equal "", errors(".well-known")
  end
end
