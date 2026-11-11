# frozen_string_literal: true
# modootoday.pwa keys (lib/modootoday/check/config/keys/serving/pwa.rb): shapes, icons, start_url and the warnings.
require_relative "../checker_case"

class CheckPwaConfigTest < CheckerCase
  def config(yaml) = page("_config.yml", "title: Example Docs\nmodootoday:\n  favicon: brand\n  pwa:\n#{yaml.gsub(/^/, '    ')}")

  def test_valid_settings_pass_strict
    config "enabled: false\nprecache: [/guides/, /]\nname: Example Docs\nshort_name: Docs\ndescription: Guides.\ndisplay: minimal-ui\nstart_url: /guides/\n" \
           "background_color: '#fafafa'\nicons:\n  - {src: /assets/a-192.png, sizes: 192x192}\n" \
           "  - {src: /assets/a-512.png, sizes: 512x512, purpose: any}\n  - {src: /assets/m.png, sizes: 512x512, purpose: maskable}\n"
    o, code = check("--strict")
    assert_equal 0, code, o
  end

  def test_shapes
    config "enabled: maybe\ndisplay: fullscreen\nname: ''\nscope: /\nstart_url: /?utm_source=app\nbackground_color: white\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "modootoday.pwa: unknown key 'scope'"
    assert_includes o, "modootoday.pwa.enabled must be true, false or kill (got \"maybe\")"
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

  def test_precache_is_a_list_of_site_paths
    ["precache: /guides/\n", "precache: ['/guides/?utm=1']\n", "precache: [//cdn.example/]\n", "precache: [guides/]\n"].each do |yaml|
      config yaml
      assert_includes check[0], "modootoday.pwa.precache must be a list of site paths without a query", yaml
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

  def test_shortcuts_and_screenshots
    config "shortcuts:\n  - {name: Guides, short_name: Guides, description: All guides., url: /guides/}\n" \
           "screenshots:\n  - {src: /s/wide.png, sizes: 1280x720, form_factor: wide, label: The home page}\n  - {src: /s/phone.png, sizes: 390x844}\n"
    o, code = check("--strict")
    assert_equal 0, code, o
    config "shortcuts: /guides/\nscreenshots: []\n"
    o, = check
    assert_includes o, "modootoday.pwa.shortcuts must be a list of {name, short_name, description, url}"
    assert_includes o, "modootoday.pwa.screenshots must be a list of {src, sizes, form_factor, label}"
    config "shortcuts:\n  - {url: '/guides/?utm=1', icon: x}\n  - Guides\n" \
           "screenshots:\n  - {src: /s/a.jpg, sizes: 1280, form_factor: tablet, label: ''}\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "modootoday.pwa.shortcuts[0]: unknown key icon"
    assert_includes o, "modootoday.pwa.shortcuts[0].name must be text"
    assert_includes o, "modootoday.pwa.shortcuts[0].url must be a site path without a query or fragment"
    assert_includes o, "modootoday.pwa.shortcuts[1] must be a map with name and url"
    assert_includes o, "modootoday.pwa.screenshots[0].src must be a site path to a .png file"
    assert_includes o, "modootoday.pwa.screenshots[0].sizes must be one size such as 1280x720 (got 1280)"
    assert_includes o, "modootoday.pwa.screenshots[0].form_factor must be wide or narrow (got \"tablet\")"
    assert_includes o, "modootoday.pwa.screenshots[0].label must be text"
  end

  def test_screenshot_warnings
    config "screenshots:\n  - {src: /s/a.png, sizes: 3000x1000}\n  - {src: /s/b.png, sizes: 200x400}\n"
    o, code = check
    assert_equal 0, code, o
    assert_includes o, "modootoday.pwa.screenshots[0]: browsers skip 3000x1000 (each side 320-3840 px, at most 2.3:1)"
    assert_includes o, "modootoday.pwa.screenshots[1]: browsers skip 200x400"
    assert_includes o, "modootoday.pwa.screenshots: none has form_factor: wide, so desktop browsers show the plain install dialog"
  end
end
