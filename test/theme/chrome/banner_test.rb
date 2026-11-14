# frozen_string_literal: true
# Site banner (chrome/banner-text.html, chrome/banner.html): text as written, release: latest from site.github, the
# {version, url} map, no banner when there is no release, and the banner sheet linked only with a banner.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class BannerTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  TAG = "https://github.com/o/r/releases/tag/v2.0.0"

  def build(banner, github: nil)
    dir = Dir.mktmpdir
    Minitest.after_run { FileUtils.rm_rf(dir) }
    src = File.join(dir, "src")
    FileUtils.mkdir_p(src)
    FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
    cfg = { "title" => "Site", "lang" => "en", "markdown" => "kramdown", "permalink" => "pretty",
            "sass" => { "silence_deprecations" => %w[import global-builtin] },
            "defaults" => [{ "scope" => { "path" => "" }, "values" => { "layout" => "doc" } }],
            "modootoday" => { "banner" => banner } }
    cfg["github"] = github if github
    File.write(File.join(src, "_config.yml"), cfg.to_yaml)
    File.write(File.join(src, "index.md"), "---\ntitle: Home\n---\n# Home\n")
    config = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
    Jekyll.logger.log_level = :error
    Dir.chdir(src) { Jekyll::Site.new(config).process }
    File.read(File.join(dir, "_site/index.html"))
  end

  def bar(html) = html[%r{<div class="mt-banner".*?</div>}m]

  def test_release_latest_reads_site_github
    h = build({ "release" => "latest" }, github: { "latest_release" => { "tag_name" => "v2.0.0", "html_url" => TAG } })
    assert_includes bar(h), %(<p>2.0.0 is out. <a href="#{TAG}"), "a leading v of the tag is dropped"
    assert_includes bar(h), ">What's new</a>"
    assert_includes h, "banner.css", "the banner sheet is linked"
  end

  def test_the_map_form_and_text_winning
    assert_includes bar(build({ "release" => { "version" => "3.1.0", "url" => "https://example.org/r" } })), "<p>3.1.0 is out. <a href=\"https://example.org/r\""
    assert_includes bar(build({ "release" => { "version" => "very-1" } })), "<p>very-1 is out.", "only a v before a digit is dropped"
    h = build({ "text" => "Maintenance tonight", "release" => "latest" }, github: { "latest_release" => { "tag_name" => "v2.0.0" } })
    assert_includes bar(h), "<p>Maintenance tonight</p>"
  end

  def test_no_release_means_no_banner
    h = build({ "release" => "latest" })
    assert_nil bar(h)
    refute_includes h, "banner.css"
  end
end
