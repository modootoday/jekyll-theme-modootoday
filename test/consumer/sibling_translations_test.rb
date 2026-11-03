# frozen_string_literal: true
# A site whose translations sit beside their sources (guide.ko.md, permalink /ko/guide/), built with the plugin and
# no stubs: twins and llms files keep the URLs a <lang>/ folder would give, and only the default root llms.txt
# lists the translations. Jekyll 4 only: github-pages does not run the plugin.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"

class SiblingTranslationsTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  GH_PAGES = Gem.loaded_specs.key?("github-pages")
  CONFIG = "title: Site\nlang: en\ntheme: jekyll-theme-modootoday\nmarkdown: kramdown\npermalink: pretty\n" \
           "sass: {silence_deprecations: [import, global-builtin]}\nplugins: [jekyll-theme-modootoday]\n" \
           "modootoday: {languages: [en, ko]}\ndefaults: [{scope: {path: ''}, values: {layout: doc}}]\n"
  PAGES = {
    "_config.yml" => CONFIG,
    "_data/i18n/ko.yml" => "language: 한국어\n",
    "index.md" => "---\ntitle: Home\n---\n# Home\n",
    "guide.md" => "---\ntitle: Guide\n---\n# Guide\n",
    "index.ko.md" => "---\nlang: ko\npermalink: /ko/\ntitle: 홈\n---\n# 홈\n",
    "guide.ko.md" => "---\nlang: ko\npermalink: /ko/guide/\ntitle: 안내\n---\n# 안내\n",
  }.freeze

  def test_plugin_serves_sibling_translations_at_language_urls
    skip "github-pages does not run the plugin" if GH_PAGES
    Dir.mktmpdir do |d|
      PAGES.each do |rel, text|
        FileUtils.mkdir_p(File.dirname("#{d}/src/#{rel}"))
        File.write("#{d}/src/#{rel}", text)
      end
      out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", "#{d}/src", "-d", "#{d}/out", chdir: ROOT)
      assert st.success?, out
      assert_equal "# 안내\n", File.read("#{d}/out/ko/guide/index.md")
      ko = File.read("#{d}/out/ko/llms.txt")
      assert_includes ko, "(/ko/guide/index.md)"
      refute_includes ko, "(/guide/index.md)"
      refute_includes ko, "## Translations"
      assert_includes File.read("#{d}/out/ko/llms-full.txt"), "# 안내"
      root = File.read("#{d}/out/llms.txt")
      assert_includes root, "## Translations"
      refute_includes root, "/ko/guide/"
      out, st = Open3.capture2e(RbConfig.ruby, "#{ROOT}/exe/modootoday-check", "#{d}/src", "#{d}/out", "--twins", chdir: ROOT)
      assert st.success?, out
    end
  end
end
