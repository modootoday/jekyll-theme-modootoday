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
  ROOT = File.expand_path("../..", __dir__)
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
      assert_match %r{href="/docs/assets/css/modootoday\.css\?v=[^"]+"}, html
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

  # A site from before the token bridge shadows the entry sheet to set $mt-overrides; the bridge hook, site_css and
  # preload come from the gem and work next to it.
  def test_token_bridge_with_a_shadowed_entry_sheet
    Dir.mktmpdir do |d|
      src = "#{d}/src"
      FileUtils.cp_r(EXAMPLE, src)
      FileUtils.rm_rf(["#{src}/_site", "#{src}/.jekyll-cache"])
      FileUtils.mkdir_p(["#{src}/assets/css", "#{src}/assets/fonts"])
      File.write("#{src}/assets/css/modootoday.scss", "---\n---\n$mt-overrides: (primary: #b45309);\n@import \"modootoday/core\";\n.site-rule { color: red; }\n")
      File.write("#{src}/_sass/modootoday/_site.scss", "$mt-overrides-base: (font-heading: (Georgia, serif));\n$mt-overrides-dark: (primary: #fbbf24);\n")
      File.write("#{src}/assets/css/site.css", ".site-sheet { color: blue; }\n")
      File.write("#{src}/assets/fonts/x.woff2", "")
      File.write("#{src}/_config.yml", File.read("#{src}/_config.yml") +
                 "modootoday: {site_css: [/assets/css/site.css], preload: [{href: /assets/fonts/x.woff2, as: font, type: font/woff2}]}\n")
      build(src, "#{d}/out")
      out, st = check(src, "#{d}/out")
      assert st.success?, out
      css = File.read("#{d}/out/assets/css/modootoday.css")
      assert_match(/--mt-primary:\s*#b45309/, css[/:root\s*\{(.*?)\}/m, 1])
      assert_match(/--mt-font-heading:\s*Georgia, serif/, css)
      assert_match(/--mt-primary:\s*#fbbf24/, css[/:root\[data-theme="?dark"?\]\s*\{(.*?)\}/m, 1])
      assert_includes css, ".site-rule"
      html = File.read("#{d}/out/guide/index.html")
      assert_match %r{<link rel="preload" href="/assets/fonts/x\.woff2" as="font" type="font/woff2" crossorigin>}, html
      assert_match %r{<link rel="stylesheet" href="/assets/css/site\.css\?v=[^"]+">}, html
      assert_operator html.index("modootoday.css"), :<, html.index("/assets/css/site.css")
    end
  end

  # Sass resolves a relative @import next to the importing theme file before the load path, so only partials the theme
  # imports as modootoday/... can be shadowed; a lone copy of an importing partial misses its siblings (Customize guide).
  def test_only_load_path_sass_partials_can_be_shadowed
    Dir.mktmpdir do |d|
      src = "#{d}/src"
      FileUtils.cp_r(EXAMPLE, src)
      FileUtils.rm_rf(["#{src}/_site", "#{src}/.jekyll-cache"])
      parts = { "_access" => true, "components/core/inline/_callout" => true, "components/section/structure/_tabs" => true,
                "_settings" => false, "tools/_mixins" => false, "tokens/_semantic" => false, "base/_prose" => false,
                "layout/_shell" => false, "blog/_post" => false }
      parts.each_key.with_index do |p, i|
        FileUtils.mkdir_p(File.dirname("#{src}/_sass/modootoday/#{p}"))
        File.write("#{src}/_sass/modootoday/#{p}.scss", File.read("#{ROOT}/_sass/modootoday/#{p}.scss") + "\n.mt-shadow-#{i} { color: red; }\n")
      end
      build(src, "#{d}/out")
      css = Dir["#{d}/out/assets/css/**/*.css"].map { File.read(_1) }.join
      parts.each_with_index { |(p, shadows), i| assert_equal shadows, css.match?(/\.mt-shadow-#{i}(?!\d)/), p }
      File.write("#{src}/_sass/modootoday/_core.scss", File.read("#{ROOT}/_sass/modootoday/_core.scss"))
      out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", src, "-d", "#{d}/core", chdir: ROOT)
      refute st.success?, "a lone copy of _core.scss cannot find its relative imports"
      assert_match(/stylesheet to import|import not found/, out)
    end
  end

  # Front-matter-less mode (modootoday.twins: source): jekyll-optional-front-matter renders each
  # front-matter-less page AND copies the raw source to its own path, which is the twin. Same on
  # github-pages (Jekyll 3.10) and Jekyll 4 with the plugins listed explicitly.
  SOURCE = File.join(EXAMPLE, "source-mode")

  def test_source_mode_twins_without_stubs
    Dir.mktmpdir do |d|
      build(SOURCE, "#{d}/out")
      out, st = check(SOURCE, "#{d}/out")
      assert st.success?, out
      { "index.md" => "index.html", "guide/index.md" => "guide/index.html", "other.md" => "other/index.html" }.each do |raw, html|
        assert_equal File.binread("#{SOURCE}/#{raw}"), File.binread("#{d}/out/#{raw}"), raw
        assert File.exist?("#{d}/out/#{html}"), html
      end
      page = File.read("#{d}/out/other/index.html")
      assert_includes page, '<link rel="alternate" type="text/markdown" href="/other.md">'
      assert_includes page, "<title>Other page"
      refute File.exist?("#{d}/out/other/index.md"), "no second twin next to the raw copy"
      assert_includes File.read("#{d}/out/llms.txt"), "(/other.md)"
      assert_includes File.read("#{d}/out/llms-full.txt"), File.read("#{SOURCE}/other.md").strip
    end
  end

  def test_source_mode_is_opt_in_and_guards_its_requirements
    Dir.mktmpdir do |d|
      src = "#{d}/src"
      FileUtils.cp_r(SOURCE, src)
      cfg = File.read("#{src}/_config.yml")
      File.write("#{src}/_config.yml", cfg.sub("  twins: source\n", "  twins: true\n"))
      build(src, "#{d}/a")
      out, st = check(src, "#{d}/a")
      refute st.success?
      assert_match(/other.md: missing front matter/, out)
      File.write("#{src}/_config.yml", cfg + "optional_front_matter: {remove_originals: true}\n")
      build(src, "#{d}/b")
      out, = check(src, "#{d}/b")
      assert_match(/remove_originals/, out)
      assert_match(/raw copy missing/, out)
      File.write("#{src}/_config.yml", cfg)
      File.write("#{src}/other.md.txt", "---\nlayout: twin\n---\n")
      out, = check(src, "#{d}/a")
      assert_match(/redundant stub/, out)
    end
  end
end
