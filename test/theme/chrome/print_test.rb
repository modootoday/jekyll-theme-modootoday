# frozen_string_literal: true
# Print sheet (modootoday.print): linked last with media="print" only when opted in, built from its unlayered partial.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class PrintSheetTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)

  def build(modootoday)
    dir = Dir.mktmpdir
    Minitest.after_run { FileUtils.rm_rf(dir) }
    src = File.join(dir, "src")
    FileUtils.mkdir_p(src)
    FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
    cfg = { "title" => "Site", "lang" => "en", "markdown" => "kramdown", "permalink" => "pretty",
            "sass" => { "silence_deprecations" => %w[import global-builtin] },
            "defaults" => [{ "scope" => { "path" => "" }, "values" => { "layout" => "doc" } }], "modootoday" => modootoday }
    File.write(File.join(src, "_config.yml"), cfg.to_yaml)
    File.write(File.join(src, "index.md"), "---\ntitle: Home\n---\n# Home\n")
    config = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
    Jekyll.logger.log_level = :error
    Dir.chdir(src) { Jekyll::Site.new(config).process }
    File.join(dir, "_site")
  end

  def test_opted_in_the_print_sheet_is_the_last_stylesheet
    s = build({ "print" => true })
    head = File.read(File.join(s, "index.html"))[%r{<head>.*</head>}m]
    links = head.scan(/<link rel="stylesheet"[^>]*>/)
    assert_match(%r{href="/assets/css/modootoday/chrome/print\.css\?v=[^"]+" media="print">\z}, links.last)
    css = File.read(File.join(s, "assets/css/modootoday/chrome/print.css"))
    refute_includes css, "@layer", "unlayered, so it wins over the layered theme"
    assert_includes css.gsub(/\s+/, " "), ".mt-toast, .mt-c-install"
    assert_match(/\.mt-actions > a\s*\{\s*background: none !important/, css, "an action button prints as an outline")
  end

  def test_off_by_default
    refute_includes File.read(File.join(build({}), "index.html")), "print.css"
  end
end
