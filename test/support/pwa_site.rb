# frozen_string_literal: true
# Builds a small site in process from the theme folders and the PWA stubs, for the test/theme/pwa tests: two pages, a
# config (title, description, kramdown, pretty permalinks, the doc layout) plus the test's YAML, and extra files.
require "tmpdir"
require "fileutils"
require "jekyll"
require_relative "../../lib/modootoday/stubs"

module PwaSite
  ROOT = File.expand_path("../..", __dir__)
  BASE = "title: Example Docs\ndescription: Guides <b>and</b> notes.\nmarkdown: kramdown\npermalink: pretty\n" \
         "time: \"2026-01-01T00:00:00+00:00\"\ndefaults: [{scope: {path: ''}, values: {layout: doc}}]\n"

  module_function

  # stub: true writes the stubs modootoday-stubs --pwa would (for languages, the offline page of each); files: path => text.
  def build(config, stub: true, languages: [], files: {})
    dir = Dir.mktmpdir
    src = File.join(dir, "src")
    FileUtils.mkdir_p(src)
    FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
    File.write(File.join(src, "_config.yml"), BASE + config)
    pages = { "index.md" => "---\ntitle: Home\n---\n# Home\n", "about.md" => "---\ntitle: About\n---\n# About\n" }.merge(files)
    stubs = Modootoday::Stubs::Pwa::FILES.merge(languages.to_h { |l| ["offline.#{l}.md", Modootoday::Stubs::Pwa.offline(l)] })
    pages.merge!(stubs) if stub
    pages.each do |name, text|
      FileUtils.mkdir_p(File.dirname(File.join(src, name)))
      File.write(File.join(src, name), text)
    end
    out = File.join(dir, "_site")
    Jekyll.logger.log_level = :error
    Dir.chdir(src) { Jekyll::Site.new(Jekyll.configuration("source" => src, "destination" => out, "quiet" => true)).process }
    at_exit { FileUtils.rm_rf(dir) }
    out
  end
end
