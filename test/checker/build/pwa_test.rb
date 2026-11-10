# frozen_string_literal: true
# modootoday.pwa in the build (lib/modootoday/check/build/pwa.rb, pwa/manifest.rb): the stub, the manifest's fields and
# scope, icon files and PNG sizes, and the manifest link on every theme page.
require "json"
require_relative "../checker_case"
require_relative "../../../lib/modootoday/stubs"

class CheckPwaBuildTest < CheckerCase
  STUB = Modootoday::Stubs::Pwa::FILES["manifest.webmanifest"]
  THEME = "<!doctype html><html lang=\"en\" data-mt-copy=\"Copy\"><head>%s</head><body></body></html>"
  LINK = "<link rel=\"manifest\" href=\"/docs/manifest.webmanifest\">"

  def png(w, h) = "\x89PNG\r\n\x1a\n".b + [13].pack("N") + "IHDR" + [w, h].pack("NN") + "\x08\x02\x00\x00\x00".b

  def manifest(**over)
    icons = [{ "src" => "/docs/i/192.png", "sizes" => "192x192", "purpose" => "any" }, { "src" => "/docs/i/512.png", "sizes" => "512x512", "purpose" => "any" }]
    { "id" => "/docs/", "name" => "Docs", "short_name" => "Docs", "start_url" => "/docs/", "scope" => "/docs/", "display" => "standalone", "icons" => icons }.merge(over)
  end

  def site(m = manifest, stub: STUB)
    page "_config.yml", "title: Docs\nmodootoday:\n  favicon: brand\n  pwa: {enabled: true, icons: brand}\n"
    page "manifest.webmanifest", stub if stub
    out "manifest.webmanifest", m.is_a?(String) ? m : JSON.generate(m)
    out "i/192.png", png(192, 192)
    out "i/512.png", png(512, 512)
    out "index.html", format(THEME, LINK)
  end

  def test_a_complete_build_passes
    site
    o, code = check("--strict")
    assert_equal 0, code, o
  end

  def test_stub_missing_or_stale
    site(stub: nil)
    assert_includes check[0], "manifest.webmanifest: missing: run modootoday-stubs SRC --pwa --write"
    site(stub: "---\nlayout: null\n---\n{% include modootoday/pwa/manifest.json %}\n")
    assert_includes check[0], "manifest.webmanifest: out of date: run modootoday-stubs SRC --pwa --write"
    site(stub: "{}\n")
    assert_includes check[0], "modootoday.pwa: manifest.webmanifest: the site's own file is where the PWA stub goes"
  end

  def test_manifest_fields_and_scope
    site("{\"name\": ")
    assert_match(%r{_site/manifest\.webmanifest: not JSON}, check[0])
    site(manifest.reject { |k, _| %w[id display].include?(k) })
    assert_match(/manifest\.webmanifest: missing id, display/, check[0])
    site(manifest("start_url" => "/other/", "id" => "/other/"))
    o, = check
    assert_includes o, "start_url \"/other/\" is outside the scope /docs/"
    assert_includes o, "id \"/other/\" is outside the scope /docs/"
    FileUtils.rm(File.join(@site, "manifest.webmanifest"))
    assert_match(/manifest\.webmanifest: missing \(run modootoday-stubs SRC --pwa --write, then build\)/, check[0])
  end

  def test_icons_exist_with_their_size
    icons = [{ "src" => "/docs/i/192.png", "sizes" => "180x180" }, { "src" => "/docs/i/none.png", "sizes" => "512x512" },
             { "src" => "/docs/index.html", "sizes" => "512x512" }, { "src" => "https://cdn.example/i.png", "sizes" => "512x512" }]
    site(manifest("icons" => icons))
    o, code = check
    assert_equal 1, code
    assert_includes o, "icon /docs/i/192.png is 192x192, not 180x180"
    assert_includes o, "icon \"/docs/i/none.png\" is not in the build"
    assert_includes o, "icon /docs/index.html is not a PNG file"
    assert_includes o, "icon \"https://cdn.example/i.png\" is not in the build"
  end

  def test_every_theme_page_links_the_manifest
    site
    out "guide/index.html", format(THEME, "")
    out "old/index.html", "<!doctype html><html><head><meta http-equiv=\"refresh\" content=\"0; url=/docs/\"></head></html>"
    o, code = check
    assert_equal 1, code
    assert_match(%r{_site/guide/index\.html: no <link rel="manifest">}, o)
    refute_match(%r{old/index\.html}, o)
  end

  def test_off_checks_nothing
    page "_config.yml", "title: Docs\nmodootoday:\n  pwa: {enabled: false}\n"
    out "index.html", format(THEME, "")
    o, code = check("--strict")
    assert_equal 0, code, o
  end
end
