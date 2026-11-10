# frozen_string_literal: true
# The web app manifest from existing settings: off links nothing; on, the stub renders JSON whose id, start_url and scope sit
# under the baseurl, whose theme_color follows modootoday.theme_color, and whose brand icons are PNG files of their size.
require "minitest/autorun"
require "json"
require_relative "../../support/pwa_site"

class PwaManifestTest < Minitest::Test
  ROOT = PwaSite::ROOT

  def self.build(config, stub: true) = PwaSite.build(config, stub: stub)

  def self.site(key, config, **opts) = ((@sites ||= {})[key] ||= build(config, **opts))

  def on = self.class.site(:on, "baseurl: /docs\nmodootoday:\n  favicon: brand\n  theme_color: {light: '#fefefe', dark: '#111111'}\n  pwa: {enabled: true, short_name: Docs}\n")

  def custom = self.class.site(:custom, "lang: ar\nmodootoday:\n  color_scheme: dark\n  theme_color: false\n  pwa:\n    enabled: true\n    name: \"Docs \\\"A\\\"\"\n" \
                                        "    start_url: /guides/\n    display: minimal-ui\n    icons: [{src: /i/a.png, sizes: 192x192}, {src: /i/m.png, sizes: 512x512, purpose: maskable}]\n")

  def json(site) = JSON.parse(File.read(File.join(site, "manifest.webmanifest")))
  def html(site, name = "index.html") = File.read(File.join(site, name))

  def test_off_links_nothing_and_writes_nothing
    off = self.class.site(:off, "modootoday: {favicon: brand}\n", stub: false)
    refute_includes html(off), "manifest"
    refute File.exist?(File.join(off, "manifest.webmanifest"))
    disabled = self.class.site(:disabled, "modootoday: {pwa: {enabled: false}}\n")
    refute_includes html(disabled), "rel=\"manifest\""
  end

  def test_on_links_the_manifest_from_every_page
    link = "<link rel=\"manifest\" href=\"/docs/manifest.webmanifest\" data-mt-sw=\"/docs/sw.js\" data-mt-scope=\"/docs/\">"
    assert_includes html(on), link
    assert_includes html(on, "about/index.html"), link
    assert_equal 1, html(on).scan("rel=\"manifest\"").size
  end

  def test_fields_come_from_existing_settings
    m = json(on)
    assert_equal %w[id name short_name description lang dir start_url scope display background_color theme_color icons], m.keys
    assert_equal ["/docs/", "/docs/", "/docs/"], m.values_at("id", "start_url", "scope")
    assert_equal ["Example Docs", "Docs", "Guides and notes."], m.values_at("name", "short_name", "description")
    assert_equal ["en", "ltr", "standalone", "#ffffff", "#fefefe"], m.values_at("lang", "dir", "display", "background_color", "theme_color")
  end

  def test_brand_icons_are_png_files_of_their_size
    icons = json(on)["icons"]
    assert_equal [%w[192x192 any], %w[512x512 any], %w[512x512 maskable]], icons.map { |i| i.values_at("sizes", "purpose") }
    icons.each do |i|
      assert_equal "image/png", i["type"]
      file = File.join(on, i["src"].delete_prefix("/docs"))
      head = File.binread(file, 24)
      assert_equal "\x89PNG\r\n\x1a\n".b, head[0, 8], i["src"]
      assert_equal i["sizes"], head[16, 8].unpack("NN").join("x")
      assert_equal File.binread(File.join(ROOT, "assets/modootoday", File.basename(file))), File.binread(file)
    end
  end

  def test_custom_settings_dark_scheme_rtl_and_no_theme_color
    m = json(custom)
    refute m.key?("theme_color")
    assert_equal ["Docs \"A\"", "Docs \"A\"", "/guides/", "/guides/", "/"], m.values_at("name", "short_name", "id", "start_url", "scope")
    assert_equal %w[ar rtl minimal-ui #0a0a0a], m.values_at("lang", "dir", "display", "background_color")
    assert_equal [{ "src" => "/i/a.png", "sizes" => "192x192", "type" => "image/png", "purpose" => "any" },
                  { "src" => "/i/m.png", "sizes" => "512x512", "type" => "image/png", "purpose" => "maskable" }], m["icons"]
    assert_includes html(custom), "<html lang=\"ar\" dir=\"rtl\""
  end
end
