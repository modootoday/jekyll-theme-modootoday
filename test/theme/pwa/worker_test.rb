# frozen_string_literal: true
# The service worker the sw.js stub renders: constants per asset_version, the scope with and without a baseurl, the precache
# list, the self-removing worker for kill and for false with the stub, and the head and script tags per mode.
require "minitest/autorun"
require "json"
require_relative "../../support/pwa_site"

class PwaWorkerTest < Minitest::Test
  STAMP = Time.utc(2026).to_i
  ON = "baseurl: /docs\nmodootoday:\n  languages: [en, ko]\n  full_languages: [ko]\n  pwa: {enabled: true, precache: [/about/]}\n"
  GUIDE = { "guide.md" => "---\ntitle: Guide\npwa: precache\n---\n# Guide\n" }.freeze

  def self.site(key, config, **opts) = ((@sites ||= {})[key] ||= PwaSite.build(config, **opts))

  def on = self.class.site(:on, ON, languages: ["ko"], files: GUIDE)
  def sw(site) = File.read(File.join(site, "sw.js"))
  def constants(site) = JSON.parse(sw(site)[/^self\.MT_PWA = (\{.*\});$/, 1])
  def html(site, page = "index.html") = File.read(File.join(site, page))
  def version = File.read(File.join(PwaSite::ROOT, "_includes/modootoday/version.html"))[/mt_version = "([^"]+)"/, 1]

  def test_constants_with_the_theme_asset_version
    c = constants(on)
    assert_equal ["/docs/", "#{version}-#{STAMP}", version], c.values_at("scope", "build", "assets")
    assert_equal({ "/docs/" => "/docs/offline/", "/docs/ko/" => "/docs/ko/offline/" }, c["offline"])
    assert_includes sw(on), "importScripts(\"/docs/assets/js/modootoday/pwa/worker.js?v=#{version}\");"
    refute_includes sw(on), "unregister"
  end

  def test_build_and_false_asset_versions_follow_the_build
    %w[build false].each do |mode|
      c = constants(self.class.site(:"v#{mode}", "modootoday:\n  asset_version: #{mode}\n  pwa: {enabled: true}\n"))
      assert_equal ["/", "#{version}-#{STAMP}", "#{version}-#{STAMP}"], c.values_at("scope", "build", "assets"), mode
    end
    assert_includes sw(self.class.site(:vfalse, "")), "importScripts(\"/assets/js/modootoday/pwa/worker.js\");"
  end

  def test_build_uses_the_short_commit
    c = constants(self.class.site(:rev, "github: {build_revision: \"0123456789abcdef\"}\nmodootoday:\n  pwa: {enabled: true}\n"))
    assert_equal ["#{version}-0123456", version], c.values_at("build", "assets")
  end

  def test_precache_lists_offline_pages_their_files_start_url_and_chosen_pages
    v = "?v=#{version}"
    assert_equal ["/docs/offline/", "/docs/ko/offline/", "/docs/assets/css/modootoday.css#{v}", "/docs/assets/css/modootoday/marketing/hero.css#{v}",
                  "/docs/assets/css/modootoday-pages.css#{v}", "/docs/assets/js/modootoday/chrome/theme-toggle.js#{v}",
                  "/docs/assets/js/modootoday/pwa/register.js#{v}", "/docs/assets/js/modootoday/pwa/offline.js#{v}", "/docs/", "/docs/about/", "/docs/guide/"],
                 constants(on)["precache"]
    c = constants(self.class.site(:start, "modootoday:\n  pwa: {enabled: true, start_url: /guide/, precache: [/guide/]}\n", files: GUIDE))
    assert_equal ["/offline/"], c["precache"].first(1)
    assert_equal ["/guide/"], c["precache"].grep(%r{\A/guide/}), "start_url, the list and the front matter name one URL once"
  end

  def test_on_links_the_worker_and_loads_register_on_every_page
    tag = "<link rel=\"manifest\" href=\"/docs/manifest.webmanifest\" data-mt-sw=\"/docs/sw.js\" data-mt-scope=\"/docs/\">"
    script = "<script type=\"module\" src=\"/docs/assets/js/modootoday/pwa/register.js?v=#{version}\"></script>"
    ["index.html", "about/index.html", "offline/index.html", "ko/offline/index.html"].each do |page|
      assert_includes html(on, page), tag, page
      assert_equal 1, html(on, page).scan(script).size, page
    end
    refute_includes html(on), "pwa/offline.js"
  end

  def test_kill_renders_the_self_removing_worker_and_links_nothing
    kill = self.class.site(:kill, "baseurl: /docs\nmodootoday:\n  pwa: {enabled: kill}\n")
    assert_includes sw(kill), "var prefix = \"mt:/docs/:\";"
    assert_includes sw(kill), "self.registration.unregister()"
    assert_includes sw(kill), "self.skipWaiting()"
    refute_includes sw(kill), "MT_PWA"
    refute_includes sw(kill), "importScripts"
    %w[manifest data-mt-sw pwa/register.js].each { |t| refute_includes html(kill), t }
  end

  def test_false_or_no_key_with_the_stub_is_the_same_kill_worker
    kill = sw(self.class.site(:kill, "baseurl: /docs\nmodootoday:\n  pwa: {enabled: kill}\n"))
    assert_equal kill, sw(self.class.site(:off, "baseurl: /docs\nmodootoday:\n  pwa: {enabled: false}\n"))
    nokey = self.class.site(:nokey, "")
    assert_includes sw(nokey), "var prefix = \"mt:/:\";"
    refute_includes html(nokey), "data-mt-sw"
  end
end
