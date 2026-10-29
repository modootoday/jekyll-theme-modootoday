# frozen_string_literal: true
# Builds the theme's CSS with the active bundle's Jekyll/Sass (Jekyll 4 + Dart Sass, or github-pages + Ruby Sass)
# under three modootoday: configs and checks the output is portable.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class CssTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  CONFIGS = {
    "all" => "",
    "bundle" => "modootoday: {css: bundle}\n",
    "minimal" => "modootoday: {components: [callout]}\n",
    "layers" => "modootoday: {css_layers: true, color_scheme: dark, components: [callout, tabs], " \
                "tokens: {primary: '#c2410c'}, tokens_dark: {primary: '#fb923c'}}\n"
  }.freeze

  def self.build(name)
    (@out ||= {})[name] ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "markdown: kramdown\nkramdown: {input: GFM}\n#{CONFIGS[name]}")
      File.write(File.join(src, "index.md"), "---\nlayout: doc\ntitle: T\n---\n# T\n\n> [!NOTE]\n> n\n")
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      s = File.join(dir, "_site")
      sheets = Dir[File.join(s, "assets/css/modootoday/**/*.css")].sort.to_h { |f| [f.delete_prefix("#{s}/assets/css/modootoday/"), File.read(f)] }
      [File.read(File.join(s, "assets/css/modootoday.css")), File.read(File.join(s, "index.html")), sheets]
    end
  end

  CONFIGS.each_key do |n|
    define_method("test_portable_#{n}") do
      css, = self.class.build(n)
      refute_match(/@(use|forward)\s|@supports\s+selector\(|--[\w-]+:\s*\$/, css)
      assert_includes css, "--mt-primary:"
      refute_match(/--md-|\.md-[a-z]/, css, "md-* aliases never shipped")
      defined = css.scan(/(--mt-[\w-]+)\s*:/).flatten
      (css.scan(/var\((--mt-[\w-]+)/).flatten.uniq - defined).each { |v| flunk "undefined #{v}" }
    end
  end

  def test_all_components_by_default
    core, html, sheets = self.class.build("all")
    css = core + sheets.values.join
    [".mt-callout", ".mt-badge", ".mt-hero", ".mt-cta", ".mt-c-features", ".mt-skeleton", ".mt-plan", ".mt-search", ".mt-code-copy", ".mt-nav", ".mt-pagination"].each { |c| assert_includes css, c, c }
    assert_match(/\[role="?tablist"?\]/, css)
    refute_includes css, "@layer"
    assert_includes html, "code-copy.js"
  end

  def test_split_sheets
    core, html, sheets = self.class.build("all")
    refute_includes core, ".mt-c-features"
    refute_includes core, ".mt-skeleton"
    assert_includes sheets.keys, "showcase/card.css"
    assert_includes sheets.keys, "loading.css"
    assert_match(/prefers-reduced-motion/, sheets["loading.css"])
    assert_match(/forced-colors/, sheets["loading.css"])
    assert_includes html, "modootoday/doc.css"
    refute_includes html, "loading.css"
  end

  def test_bundle_mode
    core, html, = self.class.build("bundle")
    assert_includes core, ".mt-c-features"
    assert_includes core, ".mt-skeleton"
    refute_includes html, "modootoday/doc.css"
  end

  def test_component_list_narrows
    css, html = self.class.build("minimal")
    assert_includes css, ".mt-callout"
    refute_includes css, ".mt-badge"
    refute_includes html, "code-copy.js"
  end

  def test_layers_and_inline_tokens
    css, html = self.class.build("layers")
    assert_match(/@layer mt\.tokens, ?mt\.base/, css)
    assert_includes html, 'data-theme="dark"'
    assert_match(/<style id="mt-tokens">[^<]*--mt-primary: ?#c2410c/, html)
    assert_includes html, "#fb923c"
  end
end
