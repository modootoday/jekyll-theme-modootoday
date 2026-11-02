# frozen_string_literal: true
# Site sources (lib/modootoday/check/source/): Sass portability and the github-pages pin. Run: bundle exec rake test
require_relative "../checker_case"

class CheckSourceTest < CheckerCase
  def test_github_pages_is_optional
    page "a.md", "---\n---\n# A\n"
    assert_equal 0, check[1]
    o, code = check("--github-pages")
    assert_equal 1, code
    assert_match(/no Gemfile.lock with github-pages/, o)
    write File.join(@src, "Gemfile.lock"), "GEM\n  specs:\n    github-pages (231)\n"
    assert_match(/github-pages 231 != 232/, check("--github-pages")[0])
    assert_equal 0, check("--github-pages=231")[1]
  end

  def test_sass_use_forward_and_supports_selector_are_errors
    page "_sass/x.scss", "// @use 'ok-in-comment';\n@use 'sass:map';\n@forward 'y';\n@supports selector(:has(a)) { a { b: c } }\n"
    o, code = check
    assert_equal 1, code
    assert_match(/x\.scss:2: @use/, o)
    assert_match(/x\.scss:3: @use\/@forward/, o)
    assert_match(/x\.scss:4: @supports selector/, o)
    refute_match(/x\.scss:1:/, o)
  end

  def test_theme_sass_sources_are_portable
    Dir.glob("#{ROOT}/{_sass,assets}/**/*.scss").each do |f|
      t = File.read(f).gsub(%r{/\*.*?\*/}m, "").gsub(%r{//[^\n]*}, "")
      refute_match(/^\s*@(use|forward)\b|@supports\s+(not\s+)?selector\(/, t, f)
      refute_match(/--[\w-]+:\s*\$/, t, "#{f}: write --x: \#{$v} (Ruby Sass prints $v literally)")
    end
  end
end
