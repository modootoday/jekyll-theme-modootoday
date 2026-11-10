# frozen_string_literal: true
# modootoday.pwa keys (lib/modootoday/check/config/keys/serving/pwa.rb): shapes, icons, start_url and the warnings.
require_relative "../checker_case"

class CheckPwaConfigTest < CheckerCase
  def config(yaml) = page("_config.yml", "title: Example Docs\nmodootoday:\n  favicon: brand\n  pwa:\n#{yaml.gsub(/^/, '    ')}")

  def test_valid_settings_pass_strict
    config "enabled: false\nname: Example Docs\nshort_name: Docs\ndescription: Guides.\ndisplay: minimal-ui\nstart_url: /guides/\n" \
           "background_color: '#fafafa'\nicons:\n  - {src: /assets/a-192.png, sizes: 192x192}\n" \
           "  - {src: /assets/a-512.png, sizes: 512x512, purpose: any}\n  - {src: /assets/m.png, sizes: 512x512, purpose: maskable}\n"
    o, code = check("--strict")
    assert_equal 0, code, o
  end

  def test_shapes
    config "enabled: kill\ndisplay: fullscreen\nname: ''\nscope: /\nstart_url: /?utm_source=app\nbackground_color: white\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "modootoday.pwa: unknown key 'scope'"
    assert_includes o, "modootoday.pwa.enabled must be true or false"
    assert_includes o, "modootoday.pwa.display must be standalone, minimal-ui, browser (got \"fullscreen\")"
    assert_includes o, "modootoday.pwa.name must be text"
    assert_includes o, "modootoday.pwa.start_url must be a site path without a query or fragment"
    assert_includes o, "modootoday.pwa.background_color must be a hex color"
    page "_config.yml", "modootoday:\n  pwa: true\n"
    assert_includes check[0], "modootoday.pwa must be a map"
    %w[//cdn.example/ /#top guides/].each do |url|
      config "start_url: #{url.inspect}\n"
      assert_includes check[0], "start_url must be a site path", url
    end
  end

  def test_icons
    config "icons: mark\n"
    assert_includes check[0], "modootoday.pwa.icons must be brand or a list"
    config "icons:\n  - {src: https://cdn.example/a.png, sizes: 192x192}\n  - {src: /a.svg, sizes: 512x256, purpose: badge, alt: x}\n  - icon.png\n"
    o, = check
    assert_includes o, "modootoday.pwa.icons[0].src must be a site path to a .png file"
    assert_includes o, "modootoday.pwa.icons[1].src must be a site path to a .png file"
    assert_includes o, "modootoday.pwa.icons[1].sizes must be one square size such as 192x192 (got \"512x256\")"
    assert_includes o, "modootoday.pwa.icons[1].purpose must be any, maskable, monochrome (got \"badge\")"
    assert_includes o, "modootoday.pwa.icons[1]: unknown key alt"
    assert_includes o, "modootoday.pwa.icons[2] must be a map with src and sizes"
    config "icons:\n  - {src: /a.png, sizes: 192x192}\n  - {src: /m.png, sizes: 512x512, purpose: maskable}\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "modootoday.pwa.icons: add a 512 px icon with purpose any"
  end

  def test_warnings
    page "_config.yml", "title: A very long documentation title\nmodootoday:\n  pwa:\n    enabled: false\n    icons:\n" \
                        "      - {src: /a.png, sizes: 192x192}\n      - {src: /b.png, sizes: 512x512}\n"
    o, code = check
    assert_equal 0, code, o
    assert_includes o, "warning: _config.yml: modootoday.pwa: the short name \"A very long documentation title\" is over 12 characters"
    assert_includes o, "warning: _config.yml: modootoday.pwa.icons: add a maskable icon"
    page "_config.yml", "title: Docs\nmodootoday:\n  pwa: {enabled: true}\n"
    assert_includes check[0], "warning: _config.yml: modootoday.pwa: the app icon is the theme's mark"
    page "_config.yml", "modootoday:\n  pwa: {enabled: true}\n"
    assert_includes check[0], "modootoday.pwa: no name (set modootoday.pwa.name or the site title)"
  end
end
