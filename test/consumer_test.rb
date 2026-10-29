# frozen_string_literal: true
# Builds real consumer sites with `jekyll build` in a subprocess, using the active bundle
# (gemfiles/github-pages.gemfile or gemfiles/jekyll4.gemfile, which both load this gem via gemspec):
#   - theme: jekyll-theme-modootoday with hand-written stubs (the example site), with and without baseurl
#   - the same site without any stub files and `plugins: [jekyll-theme-modootoday]`
#     (Jekyll 4: output must equal the stub build; github-pages: the plugin is not whitelisted, so the
#      checker must report the missing twins instead of passing silently)
# remote_theme is exercised in CI (test/remote-site) because it needs the pushed repository.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "jekyll"

class ConsumerTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  EXAMPLE = File.join(ROOT, "example")
  GH_PAGES = Gem.loaded_specs.key?("github-pages")

  def build(src, dest, *args)
    out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", src, "-d", dest, *args, chdir: ROOT)
    assert st.success?, out
  end

  def check(src, site)
    Open3.capture2e("ruby", File.join(ROOT, "exe/modootoday-check"), src, site, "--twins", chdir: ROOT)
  end

  def files(dir) = Dir.glob("**/*", base: dir).reject { |f| File.directory?(File.join(dir, f)) || f.end_with?(".map") }.sort

  def test_theme_gem_with_stubs_and_baseurl
    Dir.mktmpdir do |d|
      build(EXAMPLE, "#{d}/a")
      out, st = check(EXAMPLE, "#{d}/a")
      assert st.success?, out
      build(EXAMPLE, "#{d}/b", "--baseurl", "/docs")
      html = File.read("#{d}/b/guide/index.html")
      assert_includes html, 'href="/docs/assets/css/modootoday.css"'
      assert_includes html, 'href="/docs/guide/index.md"'
      assert_includes File.read("#{d}/b/llms.txt"), "(/docs/guide/index.md)"
      assert_equal File.binread("#{d}/a/guide/index.md"), File.binread("#{d}/b/guide/index.md")
    end
  end

  def test_plugin_generates_twins_and_llms_without_stubs
    Dir.mktmpdir do |d|
      src = "#{d}/src"
      FileUtils.cp_r(EXAMPLE, src)
      FileUtils.rm_rf(["#{src}/_site", "#{src}/.jekyll-cache"])
      Dir.glob("#{src}/**/*.txt").each { |f| File.delete(f) }
      File.write("#{src}/_config.yml", File.read("#{src}/_config.yml") + "plugins: [jekyll-theme-modootoday]\n")
      build(src, "#{d}/out")
      out, st = check(src, "#{d}/out")
      if GH_PAGES
        refute st.success?, "github-pages safe mode must not run the plugin"
        assert_match(/twin missing at .*add a stub/, out)
      else
        assert st.success?, out
        build(EXAMPLE, "#{d}/ref")
        assert_equal files("#{d}/ref"), files("#{d}/out")
        files("#{d}/ref").grep(/\.(md|txt)\z/).each do |f|
          assert_equal File.binread("#{d}/ref/#{f}"), File.binread("#{d}/out/#{f}"), f
        end
        assert_includes File.read("#{d}/out/index.html"), 'rel="alternate" type="text/markdown"'
      end
    end
  end
end
