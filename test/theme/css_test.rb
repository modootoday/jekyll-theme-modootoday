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
                "tokens: {primary: '#c2410c'}, tokens_dark: {primary: '#fb923c'}}\n",
    "empty" => "",
    "bridge" => "",
    "code-github" => "modootoday: {code_theme: github}\n",
    "langs" => "lang: en\nmodootoday: {languages: [en, ko]}\n",
    "langs-own-font" => "modootoday: {languages: [en, ko, ja]}\n",
    "langs-inline-font" => "modootoday: {languages: [en, ko], tokens: {font-sans: 'Inter, sans-serif'}}\n"
  }.freeze
  # The site's _sass/modootoday/_site.scss (token bridge) per config; without one the theme's empty copy is used.
  HOOKS = {
    "empty" => "// nothing here yet\n",
    "bridge" => "$mt-overrides-base: (font-heading: (Georgia, serif), heading-weight: 700);\n" \
                "$mt-overrides: (primary: #0f766e, link: #115e59);\n$mt-overrides-dark: (primary: #2dd4bf, link-hover: #99f6e4);\n",
    "code-github" => "$mt-overrides: (code-comment: #57606a);\n",
    "langs-own-font" => "$mt-overrides-base: (font-sans: (Inter, sans-serif));\n"
  }.freeze

  def self.build(name)
    (@out ||= {})[name] ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "markdown: kramdown\nkramdown: {input: GFM}\n#{CONFIGS[name]}")
      File.write(File.join(src, "_sass/modootoday/_site.scss"), HOOKS[name]) if HOOKS[name]
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
      (css.scan(/var\((--mt-[\w-]+)\s*\)/).flatten.uniq - defined).each { |v| flunk "undefined #{v}" }
    end
  end

  # Hooks (registry/_hooks.scss) are read with their default as the var() fallback and never declared by the theme.
  def test_hooks_are_fallbacks_only
    hooks = File.read(File.join(ROOT, "_sass/modootoday/registry/_hooks.scss")).scan(/^  "([\w-]+)": ([^\n]+?),?$/)
                .map { |n, d| [n, d.strip.sub(/\Aunquote\("(.*)"\)\z/, '\1')] }
    refute_empty hooks
    core, _, sheets = self.class.build("all")
    css = core + sheets.values.join
    hooks.each do |name, default|
      refute_match(/--mt-#{name}\s*:/, css, "the theme declares the hook --mt-#{name}")
      uses = css.scan(/var\(--mt-#{name}\s*,\s*(var\([^)]*\)|[^)]+)\)/).flatten.map(&:strip).uniq
      assert_equal [default], uses, "--mt-#{name} fallbacks"
    end
    %w[customize customize.ko customize.ja].each do |doc|
      rows = File.read(File.join(ROOT, "docs/guides/#{doc}.md")).scan(/^\| `--mt-([\w-]+)` \| `([^`]+)` \|/)
      assert_equal hooks, rows, "layout hooks table in #{doc}.md"
    end
  end

  def test_all_components_by_default
    core, html, sheets = self.class.build("all")
    css = core + sheets.values.join
    [".mt-callout", ".mt-badge", ".mt-hero", ".mt-cta", ".mt-c-features", ".mt-skeleton", ".mt-plan", ".mt-search", ".mt-code-copy", ".mt-nav", ".mt-pagination"].each { |c| assert_includes css, c, c }
    assert_match(/\[role="?tablist"?\]/, css)
    refute_includes css, "@layer"
    refute_includes html, "code-copy.js", "code-copy.js loads only on pages with a code block"
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

  def test_empty_site_hook_changes_nothing
    assert_equal self.class.build("all"), self.class.build("empty")
  end

  def test_site_hook_sets_base_light_and_dark_tokens
    css, html, sheets = self.class.build("bridge")
    root = css[/:root\s*\{(.*?)\}/m, 1]
    dark = css[/:root\[data-theme="?dark"?\]\s*\{(.*?)\}/m, 1]
    media = css[/:root:not\(\[data-theme="?light"?\]\)\s*\{(.*?)\}/m, 1]
    assert_match(/--mt-font-heading:\s*Georgia, serif;/, root)
    assert_match(/--mt-heading-weight:\s*700;/, root)
    assert_match(/--mt-primary:\s*#0f766e;/, root)
    assert_match(/--mt-link:\s*#115e59;/, root)
    assert_equal 1, root.scan("--mt-primary:").size, "merged in place, not appended"
    [dark, media].each do |d|
      assert_match(/--mt-primary:\s*#2dd4bf;/, d)
      assert_match(/--mt-link-hover:\s*#99f6e4;/, d)
      assert_match(/--mt-link:\s*var\(--mt-primary\);/, d, "untouched tokens keep the theme value")
    end
    refute_includes html, "mt-tokens", "the bridge needs no inline style"
    sheets.each { |name, s| refute_includes s, "--mt-primary:", "#{name} emits no tokens" }
  end

  def test_semantic_defaults
    css, = self.class.build("all")
    root = css[/:root\s*\{(.*?)\}/m, 1]
    dark = css[/:root\[data-theme="?dark"?\]\s*\{(.*?)\}/m, 1]
    assert_match(/--mt-font-heading:\s*var\(--mt-font-sans\);/, root)
    assert_match(/--mt-heading-weight:\s*600;/, root)
    assert_match(/--mt-link:\s*var\(--mt-primary\);/, root)
    assert_match(/--mt-link-hover:\s*var\(--mt-link\);/, root)
    assert_match(/--mt-narrow:\s*40rem;/, root)
    assert_match(/--mt-border-input:\s*#8a8a8a;/, root)
    assert_match(/--mt-border-input:\s*#737373;/, dark)
    [root, dark].each { |m| assert_match(/--mt-shadow-sm:\s*none;/, m) }
  end

  def test_flat_surfaces
    core, _, sheets = self.class.build("all")
    [core, *sheets.values].each { |s| refute_includes s, "backdrop-filter" }
    refute_match(/\.mt-callout\s*\{[^}]*color-mix/, core, "callouts are plain bordered boxes")
  end

  def test_font_stacks_only_for_declared_languages
    langs, = self.class.build("langs")
    assert_match(/:root:lang\(ko\)\s*\{\s*--mt-font-sans:\s*Pretendard Variable,\s*Pretendard,/, langs)
    refute_includes langs, ":root:lang(ja)"
    refute_includes langs, ":root:lang(en)"
    %w[all langs-own-font langs-inline-font].each { |n| refute_includes self.class.build(n).first, ":root:lang(", n }
    refute_match(/Noto Sans (KR|JP)/, self.class.build("all").first[/:root\s*\{(.*?)\}/m, 1])
  end

  def test_font_stack_keys_are_theme_languages
    codes = File.read(File.join(ROOT, "i18n/languages.yml")).scan(/code: ([\w-]+)/).flatten
    keys = File.read(File.join(ROOT, "_sass/modootoday/tokens/_fonts.scss")).scan(/^  ([\w-]+): \(/).flatten
    assert_equal %w[ko ja zh-CN zh-TW], keys
    assert_empty keys - codes
  end

  def test_code_theme_github_merges_the_preset_under_the_bridge
    css, = self.class.build("code-github")
    root = css[/:root\s*\{(.*?)\}/m, 1]
    dark = css[/:root\[data-theme="?dark"?\]\s*\{(.*?)\}/m, 1]
    media = css[/:root:not\(\[data-theme="?light"?\]\)\s*\{(.*?)\}/m, 1]
    assert_match(/--mt-code-keyword:\s*#cf222e;/, root)
    assert_match(/--mt-code-background:\s*#ffffff;/, root)
    assert_match(/--mt-code-comment:\s*#57606a;/, root, "the token bridge wins over the preset")
    assert_equal 1, root.scan("--mt-code-keyword:").size, "merged in place, not appended"
    [dark, media].each do |d|
      assert_match(/--mt-code-keyword:\s*#ff7b72;/, d)
      assert_match(/--mt-code-comment:\s*#8b949e;/, d)
    end
    default, = self.class.build("all")
    decls = /--mt-[\w-]+:[^;}]*;?/
    assert_equal default.gsub(decls, ""), css.gsub(decls, ""), "a preset changes token values only"
  end
end
