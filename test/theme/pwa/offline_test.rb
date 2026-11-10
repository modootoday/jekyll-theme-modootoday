# frozen_string_literal: true
# The offline page (layout pages/offline): noindex, localized text, a Try again link that needs no script, a home link and a
# hidden list for pwa/offline.js; every theme file it links is precached, with the notice's files; the stubs keep it out of
# search and the sitemap.
require "minitest/autorun"
require "json"
require_relative "../../support/pwa_site"

class PwaOfflineTest < Minitest::Test
  THEME_FILE = %r{(?:href|src)="(/docs/assets/(?:css|js)/modootoday[^"]*)"}
  NOTICE = %r{/chrome/toast\.css|/pwa/update-toast\.js}

  def self.site(key, config) = ((@sites ||= {})[key] ||= PwaSite.build(config, languages: ["ko"]))

  def on = self.class.site(:on, "baseurl: /docs\nmodootoday:\n  languages: [en, ko]\n  full_languages: [ko]\n  pwa: {enabled: true}\n")
  def page(site, rel) = File.read(File.join(site, rel, "index.html"))
  def precache(site) = JSON.parse(File.read(File.join(site, "sw.js"))[/^self\.MT_PWA = (\{.*\});$/, 1])["precache"]

  def test_the_page_reads_without_script_and_hides_the_list
    h = page(on, "offline")
    assert_includes h, "<meta name=\"robots\" content=\"noindex\">"
    assert_includes h, "<h1>You are offline</h1>"
    assert_includes h, "<p class=\"mt-actions\"><a href=\"\">Try again</a> <a href=\"/docs/\">Go to the home page</a></p>"
    assert_match(%r{<section data-mt-offline aria-labelledby="mt-offline-pages" hidden><h2 id="mt-offline-pages">Pages you can read offline</h2><ul></ul></section>}, h)
    assert_includes h, "pwa/offline.js?v="
    refute_includes h, "<header"
  end

  def test_each_full_language_has_its_page
    h = page(on, "ko/offline")
    assert_includes h, "<html lang=\"ko\""
    assert_includes h, "<h1>오프라인 상태예요</h1>"
    assert_includes h, ">다시 시도</a>"
  end

  def test_every_theme_file_of_the_offline_pages_is_precached
    strict = self.class.site(:strict, "baseurl: /docs\nmodootoday:\n  csp: strict\n  languages: [en, ko]\n  full_languages: [ko]\n  pwa: {enabled: true}\n")
    light = self.class.site(:light, "baseurl: /docs\nmodootoday:\n  color_scheme: light\n  languages: [en, ko]\n  full_languages: [ko]\n  pwa: {enabled: true}\n")
    [on, strict, light].each do |s|
      %w[offline ko/offline].each do |rel|
        files = page(s, rel).scan(THEME_FILE).flatten
        assert_equal files.sort, (precache(s).grep(%r{/assets/}) & files).sort, rel
        assert_equal precache(s).grep(%r{/assets/}).grep_v(NOTICE).sort, files.sort, "#{rel}: offline-assets.html lists exactly what the page links"
        assert_equal 2, precache(s).grep(NOTICE).size, "the notice's sheet and module, which also show offline"
      end
    end
    assert_includes precache(strict), "/docs/assets/js/modootoday/chrome/theme-init.js?v=#{precache(on)[2][/v=(.*)/, 1]}"
    refute(precache(light).any? { |u| u.include?("theme-") })
  end

  def test_kept_out_of_search_sitemap_and_twins
    stub = Modootoday::Stubs::Pwa::FILES["offline.md"]
    assert_equal "---\nlayout: pages/offline\npermalink: /offline/\nsitemap: false\nsearch: false\ntwin: false\n---\n", stub
    assert_equal "---\nlayout: pages/offline\nlang: ko\npermalink: /ko/offline/\nsitemap: false\nsearch: false\ntwin: false\n---\n", Modootoday::Stubs::Pwa.offline("ko")
    refute_includes page(on, "offline"), "<title>You are offline", "no title: the page stays out of title-based lists"
  end
end
