# frozen_string_literal: true
# The site's own sheets and preload hints: modootoday.site_css and modootoday.preload in _config.yml, the same front
# matter keys, and their files in the build (config/keys/serving/delivery.rb, build/site_assets.rb). Run: bundle exec rake test
require_relative "../checker_case"

class CheckSiteAssetsTest < CheckerCase
  def test_valid_settings_and_files_pass
    page "_config.yml", "modootoday:\n  site_css: [/assets/css/site.css]\n  preload: [{href: /assets/fonts/a.woff2, as: font, type: font/woff2}]\n"
    page "a.md", "---\nsite_css: [/assets/css/a.css]\npreload: [{href: /assets/img/a.webp, as: image}]\n---\n# A\n"
    %w[assets/css/site.css assets/fonts/a.woff2 assets/css/a.css assets/img/a.webp].each { |f| out f, "" }
    o, code = check("--strict")
    assert_equal 0, code, o
  end

  def test_setting_shapes
    page "_config.yml", "modootoday:\n  site_css: [https://cdn.example.org/x.css, /assets/site.scss]\n" \
                        "  preload: [{href: //cdn.example.org/a.woff2, as: audio, crossorigin: true}, /assets/b.woff2]\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "modootoday.site_css: \"https://cdn.example.org/x.css\" is not a site path to a .css file"
    assert_includes o, "modootoday.site_css: \"/assets/site.scss\" is not a site path"
    assert_includes o, "modootoday.preload[0].href must be a site path"
    assert_includes o, "modootoday.preload[0].as must be font, image, style, script, fetch (got \"audio\")"
    assert_includes o, "modootoday.preload[0]: unknown key crossorigin"
    assert_includes o, "modootoday.preload[1] must be a map with href and as"
    page "_config.yml", "modootoday:\n  site_css: /assets/css/site.css\n"
    assert_includes check[0], "modootoday.site_css must be a list"
  end

  def test_front_matter_shapes
    page "a.md", "---\nsite_css: /assets/css/a.css\npreload: [{href: /a.woff2}]\n---\n# A\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "a.md: front matter site_css must be a list"
    assert_includes o, "a.md: front matter preload[0].as must be"
  end

  def test_missing_files_in_the_build
    page "_config.yml", "modootoday:\n  site_css: [/assets/css/site.css]\n"
    page "a.md", "---\npreload: [{href: /assets/fonts/a.woff2, as: font}]\n---\n# A\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "_config.yml: modootoday.site_css /assets/css/site.css is not in the build"
    assert_includes o, "a.md: preload /assets/fonts/a.woff2 is not in the build"
  end
end
