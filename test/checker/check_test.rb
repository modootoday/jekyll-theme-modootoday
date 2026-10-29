# frozen_string_literal: true
# Tests for exe/modootoday-check. Run: bundle exec rake test
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class CheckTest < Minitest::Test
  CHECK = File.expand_path("../../exe/modootoday-check", __dir__)

  def setup
    @dir = Dir.mktmpdir
    @src = File.join(@dir, "src")
    @site = File.join(@dir, "_site")
    FileUtils.mkdir_p([@src, @site])
  end

  def teardown = FileUtils.rm_rf(@dir)

  def page(name, text) = write(File.join(@src, name), text)
  def out(name, text) = write(File.join(@site, name), text)

  def write(path, text)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, text)
  end

  # The checker runs outside the parent bundle (as users run it); never leak bundler env into it.
  CLEAN_ENV = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze

  def check(*flags)
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, @src, @site, *flags)
    [o + e, st.exitstatus]
  end

  def test_i18n_translation_keys_follow_english
    page "a.md", "---\ntitle: A\n---\n# A\n"
    page "ko/a.md", "---\ntitle: A\n---\n# A\n"
    page "ko/b.md", "---\ntitle: B\n---\n# B\n"
    write File.join(@src, "_data/i18n/en.yml"), "skip: Skip\ntoc: {label: On this page}\nhero: {cta: Start}\n"
    write File.join(@src, "_data/i18n/ko.yml"), "skip: 건너뛰기\ntoc: {lable: 목차}\n"
    o, code = check
    assert_equal 1, code, o
    assert_includes o, "_data/i18n/ko.yml: key 'toc.lable' is not in _data/i18n/en.yml"
    assert_includes o, "missing key 'hero.cta' (falls back to en)"
    refute_includes o, "missing key 'toc.label'" # the theme ships ko toc.label
    assert_includes o, "ko/b.md: no en page at b.md"
    refute_includes o, "ko/a.md: no en page"
  end

  def test_ok_page
    page "a.md", "---\ntitle: A\n---\n# A\n\n> [!NOTE]\n> hi\n"
    o, code = check
    assert_equal 0, code, o
    assert_match(/OK \(1 pages\)/, o)
  end

  def test_missing_front_matter_is_an_error
    page "a.md", "# A\n"
    o, code = check
    assert_equal 1, code
    assert_match(/a\.md: missing front matter/, o)
  end

  def test_empty_front_matter_is_fine
    page "a.md", "---\n---\n# A\n"
    assert_equal 0, check[1]
  end

  def test_forbidden_syntax
    page "a.md", "---\n---\n<div>x</div>\n{{ x }}\n{: .c}\n## H {#id}\n: def\n- > [!NOTE]\n```\n<div>ok in code</div>\n```\n"
    o, code = check
    assert_equal 1, code
    %w[raw\ HTML Liquid IAL {\#id} definition nested].each { |w| assert_includes o, w.delete("\\") }
    refute_match(/a\.md:10:/, o)
  end

  def test_status_vocabulary
    page "a.md", "---\n---\n`status:done` `status:available`\n"
    o, code = check
    assert_equal 1, code
    assert_match(/unregistered status value `status:done`/, o)
  end

  def test_sections_count
    page "a.md", "---\nsections: [a, b]\n---\n# T\n\n## A\n"
    o, code = check
    assert_equal 1, code
    assert_match(/has 2 item\(s\) but body has 1/, o)
  end

  def test_components_registry
    write File.join(@src, "_data/components.yml"), "features: {params: {cols: {allowed: [2, 3], required: true}}}\ntabs: {i18n: [tabs.label, hero.cta]}\n"
    write File.join(@src, "_data/i18n/en.yml"), "callout: {}\n"
    page "a.md", "---\nsections: [{c: features, cols: 4}, {c: nope}]\n---\n## A\n## B\n"
    o, = check
    assert_match(/cols=4 not in/, o)
    assert_match(/unknown component 'nope'/, o)
    assert_match(/missing key 'hero.cta'/, o)
    refute_match(/missing key 'tabs.label'/, o) # the theme catalog has it
  end

  def test_slot_contract
    write File.join(@src, "_data/components.yml"),
          "features: {slots: {items: {min: 2, max: 3}, lead: {max: 0}}}\n" \
          "tabs: {slots: {panels: {min: 2}, code: {required: true}}}\n" \
          "cta: {slots: {actions: {required: true}, bogus: {}}}\n"
    page "ok.md", "---\nsections: [{c: features}, {c: tabs}, {c: cta}]\n---\n# T\n\n## F\n\n- **a** x\n- **b** y\n\n" \
                  "## Tabs\n\n### A\n\n```sh\n## not a heading\n```\n\n### B\n\n```sh\nb\n```\n\n## Next\n\n[Go](x/) [More](y/)\n"
    o, = check
    refute_match(/sections\[\d\]/, o)
    assert_match(/unknown slot 'bogus'/, o)
    page "bad.md", "---\nsections: [{c: features}, {c: tabs}, {c: cta}]\n---\n# T\n\n## F\n\nIntro.\n\n- one\n- two\n- three\n- four\n\n" \
                   "## Tabs\n\n### Only\n\n## Next\n\nNo links here.\n"
    o, code = check
    assert_equal 1, code
    assert_match(/bad.md: sections\[0\] features: slot 'items' has 4 item\(s\), allows at most 3/, o)
    assert_match(/bad.md: sections\[0\] features: slot 'lead' has 1 item\(s\), allows at most 0/, o)
    assert_match(/bad.md: sections\[1\] tabs: slot 'panels' has 1 item\(s\), needs at least 2/, o)
    assert_match(/bad.md: sections\[1\] tabs: slot 'code' has 0 item\(s\), needs at least 1/, o)
    assert_match(/bad.md: sections\[2\] cta: slot 'actions' has 0 item\(s\), needs at least 1/, o)
    refute_match(/ok.md: sections/, o)
  end

  def test_registry_keys_and_ranges
    write File.join(@src, "_data/components.yml"),
          "features: {slots: {items: {min: 3, max: 2}, lead: {required: yes, most: 1}}, colour: red}\n" \
          "cta: {slots: {actions: {min: -1}}, parts: oops}\n" \
          "steps: {slots: [{items: {min: 1}}]}\n"
    page "a.md", "---\n---\n# A\n"
    o, code = check
    assert_equal 1, code
    assert_match(/features: unknown key 'colour'/, o)
    assert_match(/features.slots.items: min 3 is greater than max 2/, o)
    assert_match(/features.slots.lead: unknown key 'most'/, o)
    assert_match(/cta.slots.actions.min must be a whole number/, o)
    assert_match(/cta.parts must be a list of CSS selectors/, o)
    assert_match(/steps.slots: a list of alternative forms needs at least 2 maps/, o)
  end

  def test_slot_alternatives
    write File.join(@src, "_data/components.yml"), "steps: {slots: [{items: {min: 2}}, {panels: {min: 2}}]}\n"
    page "ok.md", "---\nsections: [{c: steps}, {c: steps}]\n---\n# T\n\n## L\n\n1. a\n2. b\n\n## H\n\n### A\n\n### B\n"
    o, = check
    refute_match(/ok.md: sections/, o)
    page "bad.md", "---\nsections: [{c: steps}]\n---\n# T\n\n## L\n\n1. a\n"
    o, code = check
    assert_equal 1, code
    assert_match(/bad.md: sections\[0\] steps: matches none of 2 slot forms \(form 1: slot 'items' has 1 item\(s\), needs at least 2; form 2: slot 'panels' has 0/, o)
  end

  def test_parts_match_api_table
    write File.join(@src, "_data/components.yml"), "tabs: {parts: ['[role=tab]', 'h3 > button[aria-expanded]', .mt-gone]}\n"
    write File.join(@src, "api.md"), "---\n---\n# API\n\n## Component structure\n\n| C | Parts |\n|---|---|\n" \
                                     "| Tabs | `[role=tab]`, `h3 > button[aria-expanded]` |\n\n## Next\n\n`.mt-gone`\n"
    o, code = check
    assert_equal 1, code
    assert_match(/tabs.parts: '.mt-gone' is not in the Component structure table of api.md/, o)
    refute_match(/'\[role=tab\]' is not/, o)
  end

  def test_parts_exist_in_built_html
    _, _, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, "-e", "require 'nokogiri'")
    skip "nokogiri not installed for this Ruby" unless st.success?
    write File.join(@src, "_data/components.yml"), "cta: {slots: {actions: {min: 1}}, parts: [.mt-cta, .mt-gone, '[role=button]']}\n"
    page "p.md", "---\nsections: [{c: cta}]\n---\n# P\n\n## Go\n\n[Start](/)\n"
    out "p/index.html", %(<section class="mt-section mt-cta" data-c="cta"><a href="/">Start</a></section><p class="mt-gone"></p>)
    o, code = check
    assert_equal 1, code
    assert_match(/cta.parts: '.mt-gone' not found in the built HTML of p.md/, o)
    refute_match(/'.mt-cta' not found/, o)
    refute_match(/role=button/, o) # runtime attributes are left to docs QA
    out "p/index.html", %(<section class="mt-section mt-cta" data-c="cta"><a class="mt-gone" href="/">Start</a></section>)
    o, code = check
    assert_equal 0, code, o
  end

  def test_build_residue
    page "a.md", "---\n---\n# A\n"
    out "a/index.html", "<p>[!NOTE]</p><code>status:available</code>"
    o, code = check
    assert_equal 1, code
    assert_match(/unconverted alert marker/, o)
    assert_match(/unconverted status badge/, o)
  end

  def test_unknown_alert_type_is_an_error
    page "a.md", "---\n---\n> [!FOO]\n> x\n"
    o, code = check
    assert_equal 1, code
    assert_match(/unregistered alert type \[!FOO\]/, o)
  end

  def test_strict_turns_warnings_into_errors
    page "a.md", "---\n---\n> [! NOTE]\n> x\n"
    o, code = check
    assert_equal 0, code, o
    assert_match(/warning: .*with a space is not an alert/, o)
    assert_equal 1, check("--strict")[1]
  end

  def test_residue_ignores_code_and_matches_any_case
    page "a.md", "---\n---\n# A\n"
    out "a/index.html", "<pre><code>[!NOTE]</code></pre><p>`<code>[!TIP]</code>`</p>"
    assert_equal 0, check[1]
    out "a/index.html", "<p>[!note]</p>"
    assert_match(/unconverted alert marker \[!note\]/, check[0])
  end

  # Audit fixtures (test/fixtures/md): source → expected checker messages ([] = clean).
  FIX = File.expand_path("../fixtures/md", __dir__)
  EXPECT = {
    "a01-note" => [], "a06-lowercase" => [], "a07-mixedcase" => [], "a09-multipara" => [], "a14-crlf" => [],
    "a16-lazy-continuation" => [], "a17-blank-gt-after" => [], "a19-code-inside" => [], "a21-inline-first-body" => [],
    "a22-no-space" => [], "a23-indented-3sp" => [], "a24-list-first-body" => [], "a25-two-adjacent" => [],
    "a28-trailing-spaces" => [], "a27-heading-first" => ["'##' inside a quote/alert"],
    "a08-unknown-type" => ["unregistered alert type [!FOO]"],
    "a10-trailing-text" => ["text after [!NOTE]"],
    "a11-nested" => ["alert nested"], "a12-in-list" => ["alert nested"], "a13-in-table" => ["alert nested"],
    "a15-tab-after-gt" => ["tab after '>'"],
    "a18-empty" => ["empty alert"],
    "a20-bold-title-line" => ["formatted alert marker"],
    "a29-h2-in-alert-sections" => ["'##' inside a quote/alert"],
    "s01-setext" => ["setext heading"],
    "s03-hash-in-quote" => ["'##' inside a quote/alert"],
    "s05-indented-hash" => ["indented '##'"],
    "s06-hash-in-html-comment" => ["HTML comment", "'##' inside an HTML comment"],
    "s09-h2-in-list" => ["'##' inside a list item"],
    "s02-hash-in-fence" => [], "s04-trailing-hashes" => [], "s07-no-space" => [], "s08-fence-4backticks" => [],
    "t01-tabs-backtick" => [], "t02-tabs-tilde" => [], "t03-tabs-indented" => [], "m01-mermaid" => [],
    "t04-info-attrs" => ["info string must be a single language word"],
    "t05-info-space-attr" => ["info string must be a single language word"],
    "t06-info-lang-only-tilde-attr" => ["info string must be a single language word"],
    "f01-raw-html-in-code" => [], "f09-tasklist-strike" => [], "f10-footnote" => [], "f17-autolink-angle" => [],
    "f18-hard-break" => [], "g01-table" => [], "b01-badge" => [], "c01-cta" => [], "c02-cta-separator" => [], "c03-card-emdash" => [],
    "f02-html-comment" => ["HTML comment"], "f04-ial" => ["IAL"], "f05-header-id" => ["{#id}"], "f06-deflist" => ["definition list"],
    "f07-raw-details" => ["raw HTML"], "f08-autolink-email" => ["bare URL"], "f12-liquid-in-text" => ["Liquid"],
    "f13-kramdown-toc" => ["IAL"], "f14-abbr" => ["abbreviation"], "f16-tagfilter" => ["raw HTML"], "f19-html-inline-kbd" => ["raw HTML"]
  }.freeze
  SECS = { "a29-h2-in-alert-sections" => 1, "s02-hash-in-fence" => 1, "s03-hash-in-quote" => 1, "s04-trailing-hashes" => 2,
           "s06-hash-in-html-comment" => 1, "s08-fence-4backticks" => 1, "s09-h2-in-list" => 1, "s01-setext" => 1 }.freeze

  EXPECT.each do |name, msgs|
    define_method("test_fixture_#{name.tr('-', '_')}") do
      secs = SECS[name] ? "sections: [#{(1..SECS[name]).map { |i| "s#{i}" }.join(', ')}]\n" : ""
      write File.join(@src, "#{name}.md"), "---\n#{secs}---\n" + File.binread(File.join(FIX, "#{name}.md"))
      o, code = check
      if msgs.empty?
        assert_equal 0, code, o
      else
        assert_equal 1, code, o
        msgs.each { |m| assert_includes o, m }
      end
    end
  end

  def test_every_fixture_has_an_expectation
    covered = EXPECT.keys + %w[a02-tip a03-important a04-warning a05-caution a26-space-inside b02-badge-double-backtick
                               f03-liquid-in-code f11-math-dollar f15-smart-quotes]
    assert_empty Dir.children(FIX).map { |f| File.basename(f, ".md") } - covered
  end

  def test_github_pages_is_optional
    page "a.md", "---\n---\n# A\n"
    assert_equal 0, check[1]
    o, code = check("--github-pages")
    assert_equal 1, code
    assert_match(/no Gemfile.lock with github-pages/, o)
    write File.join(@src, "Gemfile.lock"), "GEM\n  specs:\n    github-pages (231)\n"
    assert_match(/github-pages 231 != 232/, check("--github-pages")[0])
    assert_equal 0, check("--github-pages=231")[1]
  end

  def test_twins
    page "index.md", "---\ntitle: T\n---\n# T\n"
    page "index.md.txt", "---\nlayout: twin\ntwin_of: index.md\npermalink: /index.md\n---\n"
    page "g.md", "---\n---\n# G\n"
    page "h.md", "---\ntwin: false\n---\n# H\n"
    out "index.md", "# T\n"
    out "llms.txt", ""
    out "llms-full.txt", "# T\n"
    o, code = check("--twins")
    assert_equal 1, code
    assert_match(/g\.md: twin missing at .*g\/index\.md: add a stub g\.md\.txt .*plugins: \[jekyll-theme-modootoday\]/, o)
    assert_match(/llms\.txt: must start with an H1/, o)
    assert_match(/llms-full\.txt: does not contain the body of g\.md/, o)
    refute_match(/index\.md: twin|h\.md/, o)
    out "g/index.md", "# G\n"
    out "llms.txt", "# Site\n"
    out "llms-full.txt", "# T\n\n# G\n"
    assert_equal ["", 0], [check("--twins")[0][/^(?!md-components).*$/].to_s, check("--twins")[1]]
    out "index.md", "# T changed\n"
    assert_match(/not byte-identical/, check("--twins")[0])
  end

  def test_stub_must_use_twin_layout
    page "a.md", "---\n---\n# A\n"
    page "a.md.txt", "---\nlayout: doc\n---\n"
    assert_match(/a\.md\.txt: stub must set layout: twin/, check("--twins")[0])
  end

  def test_usage
    _, _, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK)
    refute st.success?
    o, st = Open3.capture2(CLEAN_ENV, RbConfig.ruby, CHECK, "--help")
    assert st.success?
    assert_match(/usage: modootoday-check/, o)
  end

  def test_sass_use_forward_and_supports_selector_are_errors
    page "_sass/x.scss", "// @use 'ok-in-comment';\n@use 'sass:map';\n@forward 'y';\n@supports selector(:has(a)) { a { b: c } }\n"
    o, code = check
    assert_equal 1, code
    assert_match(/x\.scss:2: @use/, o)
    assert_match(/x\.scss:3: @use\/@forward/, o)
    assert_match(/x\.scss:4: @supports selector/, o)
    refute_match(/x\.scss:1:/, o)
  end

  def test_built_css_portability_and_undefined_tokens
    out "a.css", "@use \"x\";\n:root { --mt-a: 1px; --mt-b: $v; }\na { margin: var(--mt-a); color: var(--mt-missing); }\n"
    out "i.html", "<style id=\"mt-tokens\">:root{--mt-inline:red}</style><style>a{}</style>"
    out "b.css", "b { color: var(--mt-inline); }"
    o, code = check
    assert_equal 1, code
    assert_includes o, "@use/@forward left in built CSS"
    assert_includes o, "literal Sass variable"
    assert_includes o, "var(--mt-missing) is never defined"
    refute_includes o, "--mt-inline) is never"
    refute_includes o, "var(--mt-a) is never"
  end

  def test_modootoday_config_validation
    page "_config.yml", "modootoday:\n  color_scheme: blue\n  css_layers: yes please\n  components: [callout, carousel]\n" \
                        "  tokens: {primary: '#c2410c', accent: '#zz0000', foo: '1rem'}\n  tokens_dark: {primary: '#fb923c}x'}\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "color_scheme must be auto, light or dark"
    assert_includes o, "css_layers must be true or false"
    assert_includes o, "unknown component 'carousel'"
    refute_includes o, "unknown component 'callout'"
    assert_includes o, "tokens.accent: invalid hex color"
    assert_includes o, "tokens_dark.primary: invalid CSS value"
    assert_includes o, "tokens.foo: not a semantic token"
    refute_includes o, "tokens.primary"
  end

  def test_valid_modootoday_config
    page "_config.yml", "modootoday:\n  color_scheme: dark\n  css_layers: true\n  components: [callout, code-copy]\n" \
                        "  tokens: {primary: 'oklch(0.6 0.2 40)', radius: 0.5rem, font-sans: '\"Inter\", sans-serif'}\n"
    o, code = check("--strict")
    assert_equal 0, code, o
  end

  def test_theme_sass_sources_are_portable
    root = File.expand_path("../..", __dir__)
    Dir.glob("#{root}/{_sass,assets}/**/*.scss").each do |f|
      t = File.read(f).gsub(%r{/\*.*?\*/}m, "").gsub(%r{//[^\n]*}, "")
      refute_match(/^\s*@(use|forward)\b|@supports\s+(not\s+)?selector\(/, t, f)
      refute_match(/--[\w-]+:\s*\$/, t, "#{f}: write --x: \#{$v} (Ruby Sass prints $v literally)")
    end
  end


  def test_tag_values_since_rejected_and_image_alt
    page "a.md", "---\n---\n`tag:beta` `since:1.0` `tag:two words` `![](ok-in-code)`\n\n![](x.png)\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "`tag:two words` badge value"
    assert_includes o, "`since:1.0` is not supported before 1.1"
    refute_includes o, "`tag:beta`"
    assert_includes o, "image without alt text"
  end

  def test_v03_components_are_known
    page "_config.yml", "modootoday:\n  components: [theme-toggle, breadcrumb, toc, accordion, steps, figure]\n"
    assert_equal 0, check[1]
  end


  def test_kbd_value_format
    page "a.md", "---\n---\n`kbd:Ctrl+K` `kbd:a b` `kbd:Ctrl++`\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "`kbd:a b` must be keys"
    assert_includes o, "`kbd:Ctrl++` must be keys"
    refute_includes o, "`kbd:Ctrl+K` must"
  end

  def test_head_option_validation
    page "_config.yml", "modootoday:\n  csp: loose\n  languages: [en, Korean]\n  edit_url: github.com/x\n  seo: maybe\n  feed: true\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "csp must be strict or false"
    assert_includes o, "languages must be a list"
    assert_includes o, "edit_url must be an http(s) URL"
    assert_includes o, "seo must be true or false"
    assert_includes o, "add jekyll-feed to plugins"
  end

  def test_valid_head_options
    page "_config.yml", "plugins: [jekyll-feed]\nmodootoday:\n  csp: strict\n  languages: [en, ko, zh-Hant]\n" \
                        "  edit_url: https://github.com/o/r/edit/main/docs/\n  seo: false\n  feed: true\n"
    o, code = check("--strict")
    assert_equal 0, code, o
  end

end
