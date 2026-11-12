# frozen_string_literal: true
# Page footer line from site.github (meta/github.html): edit_url: auto from the Pages source branch and folder, an
# explicit URL winning, edit: false, build_link with a known repository and commit, and nothing when site.github is empty.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class PageMetaTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  REPO = "https://github.com/o/r"
  REV = "0123456789abcdef0123456789abcdef01234567"

  def build(modootoday, github)
    dir = Dir.mktmpdir
    Minitest.after_run { FileUtils.rm_rf(dir) }
    src = File.join(dir, "src")
    FileUtils.mkdir_p(File.join(src, "guide"))
    FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
    cfg = { "title" => "Site", "lang" => "en", "markdown" => "kramdown", "permalink" => "pretty",
            "sass" => { "silence_deprecations" => %w[import global-builtin] },
            "defaults" => [{ "scope" => { "path" => "" }, "values" => { "layout" => "doc" } }],
            "modootoday" => modootoday }
    cfg["github"] = github if github
    File.write(File.join(src, "_config.yml"), cfg.to_yaml)
    File.write(File.join(src, "guide/index.md"), "---\ntitle: Guide\n---\n# Guide\n")
    File.write(File.join(src, "quiet.md"), "---\ntitle: Quiet\nedit: false\n---\n# Quiet\n")
    config = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
    Jekyll.logger.log_level = :error
    Dir.chdir(src) { Jekyll::Site.new(config).process }
    File.join(dir, "_site")
  end

  def meta(site, rel) = File.read(File.join(site, rel))[%r{<p class="mt-page-meta">.*?</p>}m]

  def github(path: "/docs", rev: REV) = { "repository_url" => REPO, "source" => { "branch" => "main", "path" => path }, "build_revision" => rev }

  def test_auto_builds_the_edit_url_from_the_pages_source_folder
    s = build({ "edit_url" => "auto" }, github)
    assert_includes meta(s, "guide/index.html"), %(href="#{REPO}/edit/main/docs/guide/index.md")
    assert_nil meta(s, "quiet/index.html"), "edit: false and nothing else to show"
    assert_includes File.read(File.join(s, "guide/index.html")), "doc-nav.css", "the row's sheet is linked"
  end

  def test_a_root_source_adds_no_folder
    s = build({ "edit_url" => "auto" }, github(path: "/"))
    assert_includes meta(s, "guide/index.html"), %(href="#{REPO}/edit/main/guide/index.md")
  end

  def test_an_explicit_url_wins_over_site_github
    s = build({ "edit_url" => "https://example.org/edit/" }, github)
    assert_includes meta(s, "guide/index.html"), 'href="https://example.org/edit/guide/index.md"'
  end

  def test_build_link_names_and_links_the_commit
    h = meta(build({ "build_link" => true }, github), "guide/index.html")
    assert_includes h, %(<a href="#{REPO}/commit/#{REV}" rel="nofollow">Built from 0123456</a>)
    refute_includes h, "/edit/"
  end

  def test_without_site_github_nothing_is_shown
    s = build({ "edit_url" => "auto", "build_link" => true }, nil)
    assert_nil meta(s, "guide/index.html")
  end
end
