# frozen_string_literal: true
# script: and poster: on hero: and sections: items (page/hero_script.rb), and the modootoday.scripts entries they name
# (config/keys/serving/delivery.rb, build/site_assets.rb). Run: bundle exec rake test
require_relative "../checker_case"

class CheckHeroScriptTest < CheckerCase
  CONFIG = "modootoday:\n  scripts:\n    orbit: {src: /assets/js/orbit.js, css: /assets/css/orbit.css, preload: [/assets/js/scene.js], element: x-orbit}\n"
  BODY = "# A\n\nLead.\n\n## One\n\nText.\n"

  def built(*files) = files.each { |f| out f, "" }

  def test_valid_script_and_poster_pass
    page "_config.yml", CONFIG
    page "a.md", "---\nhero: {c: split, script: orbit, poster: {path: /assets/p.webp, width: 640, height: 480}}\nsections: [{name: one, script: orbit, poster: {path: /assets/p.webp, srcset: \"/assets/p.webp 640w\", sizes: 50vw, width: 640, height: 480}}]\n---\n#{BODY}"
    page "assets/p.webp", ""
    built "assets/js/orbit.js", "assets/css/orbit.css", "assets/js/scene.js"
    o, code = check("--strict")
    assert_equal 0, code, o
  end

  def test_script_must_be_registered_and_poster_sized
    page "_config.yml", CONFIG
    page "a.md", "---\nhero: {script: comet, poster: /assets/p.webp}\nsections: [{name: one, poster: {path: https://cdn.example.org/p.webp}}]\n---\n#{BODY}"
    o, code = check
    assert_equal 1, code
    assert_includes o, "a.md: hero.script: \"comet\" is not in modootoday.scripts (_config.yml)"
    assert_includes o, "a.md: hero.poster needs width and height in pixels"
    assert_includes o, "a.md: hero.poster: /assets/p.webp not found in the site"
    assert_includes o, "a.md: sections[0].poster must be a site path or {path, width, height}"
  end

  def test_poster_keys_and_visual_code
    page "_config.yml", CONFIG
    page "a.md", "---\nsections: [{c: split, name: one, visual: code, script: orbit, poster: {path: /p.webp, width: 1, height: 1, alt: x}}]\n---\n# A\n\n## One\n\n```sh\nx\n```\n"
    page "p.webp", ""
    o, code = check
    assert_equal 1, code
    assert_includes o, "a.md: sections[0]: script: and poster: do not go with visual: code"
    assert_includes o, "a.md: sections[0].poster: unknown key alt (path, srcset, sizes, width, height)"
  end

  def test_split_with_a_script_needs_no_visual
    page "_config.yml", CONFIG
    page "a.md", "---\nhero: {c: split, script: orbit}\nsections: [{c: split, name: one, script: orbit}]\n---\n#{BODY}"
    o, = check
    refute_includes o, "needs visual"
  end

  def test_scripts_setting_shapes
    page "_config.yml", "modootoday:\n  scripts:\n    Orbit: {src: /a.js}\n    cdn: {src: https://cdn.example.org/a.js}\n" \
                        "    odd: {src: /a.js, css: /a.scss, preload: /b.js, element: orbit, async: true}\n    bare: /a.js\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "modootoday.scripts[Orbit]: the name must be lowercase letters, digits and hyphens"
    assert_includes o, "modootoday.scripts[cdn].src must be a site path to a .js file"
    assert_includes o, "modootoday.scripts[odd].css must be a site path to a .css file"
    assert_includes o, "modootoday.scripts[odd].preload must be a list of site paths to .js files"
    assert_includes o, "modootoday.scripts[odd].element must be a custom element name with a hyphen"
    assert_includes o, "modootoday.scripts[odd]: unknown key async (src, css, preload, element)"
    assert_includes o, "modootoday.scripts[bare] must be a map with src"
    page "_config.yml", "modootoday:\n  scripts: [orbit]\n"
    assert_includes check[0], "modootoday.scripts must be a map of names to {src, css, preload, element}"
  end

  def test_script_files_must_be_in_the_build
    page "_config.yml", CONFIG
    built "assets/js/orbit.js"
    o, code = check
    assert_equal 1, code
    assert_includes o, "_config.yml: modootoday.scripts[orbit].css /assets/css/orbit.css is not in the build"
    assert_includes o, "_config.yml: modootoday.scripts[orbit].preload /assets/js/scene.js is not in the build"
    refute_includes o, "orbit.js is not in the build"
  end
end
