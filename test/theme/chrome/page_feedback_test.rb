# frozen_string_literal: true
# Page feedback row (meta/feedback.html): prefilled issue links with encoded ko/ja titles and labels, the two helpful
# answers, Discuss, issues: auto through a github: map, and the site-wide and per-page off switches.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "cgi"
require "jekyll"

class PageFeedbackTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  ISSUES = "https://github.com/o/r/issues"

  def build(feedback, github: nil)
    dir = Dir.mktmpdir
    Minitest.after_run { FileUtils.rm_rf(dir) }
    src = File.join(dir, "src")
    FileUtils.mkdir_p(File.join(src, "ko"))
    FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
    cfg = { "title" => "Site", "lang" => "en", "url" => "https://example.org", "markdown" => "kramdown", "permalink" => "pretty",
            "sass" => { "silence_deprecations" => %w[import global-builtin] },
            "defaults" => [{ "scope" => { "path" => "" }, "values" => { "layout" => "doc" } }, { "scope" => { "path" => "ko" }, "values" => { "lang" => "ko" } }],
            "modootoday" => { "feedback" => feedback } }
    cfg["github"] = github if github
    File.write(File.join(src, "_config.yml"), cfg.to_yaml)
    File.write(File.join(src, "guide.md"), "---\ntitle: Guide\n---\n# Guide\n")
    File.write(File.join(src, "ko/guide.md"), "---\ntitle: 설정 안내\n---\n# 설정 안내\n")
    File.write(File.join(src, "quiet.md"), "---\ntitle: Quiet\nfeedback: false\n---\n# Quiet\n")
    config = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
    Jekyll.logger.log_level = :error
    Dir.chdir(src) { Jekyll::Site.new(config).process }
    File.join(dir, "_site")
  end

  def row(site, rel) = File.read(File.join(site, rel))[%r{<p class="mt-page-feedback">.*?</p>}m]

  def enc(text) = CGI.escape(text)

  def test_all_three_links_are_prefilled_and_encoded
    s = build({ "issues" => ISSUES, "helpful" => true, "discuss" => "https://github.com/o/r/discussions", "labels" => %w[docs-feedback] })
    h = row(s, "guide/index.html")
    q = "&amp;body=#{enc("Page: https://example.org/guide/")}&amp;labels=docs-feedback"
    assert_includes h, %(<a href="#{ISSUES}/new?title=Guide#{q}" rel="nofollow">Report an issue</a>)
    assert_includes h, %(<span>Was this page helpful? <a href="#{ISSUES}/new?title=#{enc("Helpful: Guide")}#{q}" rel="nofollow">Yes</a> )
    assert_includes h, %(<a href="#{ISSUES}/new?title=#{enc("Not helpful: Guide")}#{q}" rel="nofollow">No</a></span>)
    assert_includes h, %(<a href="https://github.com/o/r/discussions" rel="nofollow">Discuss</a>)
    k = row(s, "ko/guide/index.html")
    assert_includes k, "title=#{enc("설정 안내")}&amp;", "a Korean title is percent-encoded"
    assert_includes k, ">문제 신고</a>"
    assert_nil row(s, "quiet/index.html"), "feedback: false hides the row"
  end

  def test_issues_auto_reads_the_repository_and_off_shows_nothing
    s = build({ "issues" => "auto" }, github: { "repository_url" => "https://github.com/o/r" })
    assert_includes row(s, "guide/index.html"), %(href="#{ISSUES}/new?title=Guide&amp;body=)
    assert_nil row(build({ "issues" => "auto" }), "guide/index.html"), "auto without site.github shows nothing"
    assert_nil row(build({ "issues" => false, "helpful" => true }), "guide/index.html"), "helpful needs issues"
  end
end
