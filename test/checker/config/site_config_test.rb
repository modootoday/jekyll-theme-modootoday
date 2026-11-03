# frozen_string_literal: true
# The modootoday: settings in _config.yml (lib/modootoday/check/config/). Run: bundle exec rake test
require_relative "../checker_case"

class CheckSiteConfigTest < CheckerCase
  def test_modootoday_config_validation
    page "_config.yml", "modootoday:\n  color_scheme: blue\n  css_layers: yes please\n  sidebar: left\n  page_actions: maybe\n  components: [callout, carousel]\n" \
                        "  tokens: {primary: '#c2410c', accent: '#zz0000', foo: '1rem'}\n  tokens_dark: {primary: '#fb923c}x'}\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "color_scheme must be auto, auto-dark, auto-light, light or dark"
    assert_includes o, "sidebar must be auto, true or false"
    assert_includes o, "page_actions must be true or false"
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

  def test_v03_components_are_known
    page "_config.yml", "modootoday:\n  components: [theme-toggle, breadcrumb, toc, accordion, steps, figure]\n"
    assert_equal 0, check[1]
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

  def test_asset_version_validation
    %w[theme build false].each do |v|
      page "_config.yml", "modootoday:\n  asset_version: #{v}\n"
      o, code = check("--strict")
      assert_equal 0, code, "#{v}: #{o}"
    end
    page "_config.yml", "modootoday:\n  asset_version: true\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "asset_version must be theme, build or false (got true)"
  end

  def test_code_theme_validation
    page "_config.yml", "modootoday:\n  code_theme: github\n  tokens: {code-keyword: '#cf222e'}\n"
    o, code = check("--strict")
    assert_equal 0, code, o
    page "_config.yml", "modootoday:\n  code_theme: monokai\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "code_theme must be theme or github (got \"monokai\")"
    ["highlighter: none\n", "kramdown: {syntax_highlighter: coderay}\n"].each do |cfg|
      page "_config.yml", "#{cfg}modootoday:\n  code_theme: github\n"
      assert_includes check[0], "code_theme: colours Rouge output only", cfg
    end
    page "_config.yml", "highlighter: none\nmodootoday:\n  code_theme: theme\n"
    refute_includes check[0], "code_theme"
  end
end
