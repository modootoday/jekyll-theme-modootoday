# frozen_string_literal: true
# modootoday-check: link.html ref= targets, --i18n-pages (warning; --strict fails), full_languages, decor:, .mt-illustration.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class I18nPagesTest < Minitest::Test
  CHECK = File.expand_path("../../exe/modootoday-check", __dir__)
  CLEAN_ENV = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze

  def setup
    @dir = Dir.mktmpdir
    FileUtils.mkdir_p(%w[src/ko _site].map { |d| File.join(@dir, d) })
  end

  def teardown = FileUtils.rm_rf(@dir)

  def put(path, text) = File.write(File.join(@dir, path), text)

  def run_check(*opts)
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, File.join(@dir, "src"), File.join(@dir, "_site"), *opts)
    [o + e, st.exitstatus]
  end

  def site(full = "[ko]")
    put("src/_config.yml", "lang: en\nmodootoday:\n  languages: [en, ko]\n  full_languages: #{full}\n")
    FileUtils.mkdir_p(File.join(@dir, "src/_includes"))
    put("src/_includes/nav.html", '<a href="{% include modootoday/link.html ref="b" %}">B</a>')
    put("src/a.md", "---\ntitle: A\nref: a\n---\n# A\n")
    put("src/b.md", "---\ntitle: B\nref: b\n---\n# B\n")
    put("src/c.md", "---\ntitle: C\n---\n# C\n")
    put("src/ko/anything.md", "---\ntitle: 가\nref: a\nlang: ko\n---\n# 가\n")
    put("src/ko/c.md", "---\ntitle: 다\nlang: ko\n---\n# 다\n")
  end

  def test_missing_translation_warns_then_strict_fails
    site
    out, st = run_check("--i18n-pages")
    assert_equal 0, st, out
    assert_includes out, "b.md: no ko page (ref: b)"
    refute_match(/a\.md: no ko|c\.md: no ko/, out)
    out, st = run_check("--i18n-pages", "--strict")
    assert_equal 1, st, out
    out, = run_check
    refute_includes out, "no ko page"
  end

  def test_unknown_ref_and_full_languages_fail
    site("[ko, fr]")
    put("src/_includes/nav.html", '<a href="{% include modootoday/link.html ref="nope" %}">X</a>')
    put("src/ko/c.md", "---\ntitle: 다\nlang: ko\n---\n# 다\n\nWrite `{% include modootoday/link.html ref=\"doc\" %}` in an include.\n")
    out, st = run_check
    assert_equal 1, st
    assert_includes out, 'ref="nope": no page has front matter ref: nope'
    refute_includes out, 'ref="doc"'
    assert_includes out, "full_languages: 'fr' is not in modootoday.languages"
  end

  def test_decor_include_must_exist
    put("src/a.md", "---\ntitle: A\nhero: {decor: gone}\nsections: [{name: s, decor: \"Bad\"}]\n---\n# A\n\nLead.\n\n## S\n\nx\n")
    out, st = run_check
    assert_equal 1, st
    assert_includes out, "hero.decor: _includes/sections/gone.html not found"
    assert_includes out, "decor must be an include name"
  end

  def test_illustration_needs_figure_role_img_and_label
    put("src/a.md", "---\ntitle: A\n---\n# A\n")
    put("_site/ok.html", '<figure class="mt-illustration" role="img" aria-label="A cat"><svg></svg></figure>')
    out, st = run_check
    assert_equal 0, st, out
    put("_site/bad.html", '<div class="mt-illustration"></div><figure class="mt-illustration" role="img" aria-label=" "></figure><span class="mt-illustration-tag">x</span>')
    out, st = run_check
    assert_equal 1, st
    assert_equal 2, out.scan(".mt-illustration must be").size, out
  end
end
