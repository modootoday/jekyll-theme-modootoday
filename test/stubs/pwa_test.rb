# frozen_string_literal: true
# modootoday-stubs --pwa: the manifest, worker and offline page stubs, preview, write and check, never pruned, a site file at a
# stub path, the offline page per full language, the config gate (true or kill) and the stubs of the PWA fixture site.
require_relative "stubs_case"
require_relative "../../lib/modootoday/stubs"

class StubsPwaTest < StubsCase
  ON = "modootoday:\n  pwa: {enabled: true}\n"

  def test_preview_write_and_check
    config ON
    assert_equal({ "manifest.webmanifest" => "create", "offline.md" => "create", "sw.js" => "create" }, plan("--pwa"))
    refute exist?("manifest.webmanifest"), "preview writes nothing"
    assert_equal 1, stubs("--pwa", "--check")[2]
    stubs("--pwa", "--write")
    assert_equal Modootoday::Stubs::Pwa::FILES["manifest.webmanifest"], read("manifest.webmanifest")
    assert_equal "---\nlayout: null\npermalink: /manifest.webmanifest\nsitemap: false\n---\n{% include modootoday/pwa/manifest.json %}\n", read("manifest.webmanifest")
    assert_equal "---\nlayout: null\npermalink: /sw.js\nsitemap: false\n---\n{% include modootoday/pwa/sw.js %}\n", read("sw.js")
    assert_equal Modootoday::Stubs::Pwa::FILES["offline.md"], read("offline.md")
    assert_equal 0, stubs("--pwa", "--check")[2]
    file "manifest.webmanifest", "---\nlayout: null\n---\n{% include modootoday/pwa/manifest.json %}\n"
    assert_equal({ "manifest.webmanifest" => "update" }, plan("--pwa"))
  end

  def test_never_pruned_and_other_kinds_leave_it
    config ON
    file "guide.md", "---\ntitle: Guide\n---\n# Guide\n"
    stubs("--pwa", "--write")
    assert_equal({ "guide.md.txt" => "create" }, plan("--twins"))
    assert_equal({ "guide.md.txt" => "create" }, plan("--twins", "--pwa"))
    config "modootoday:\n  pwa: {enabled: true}\n  aliases: {html: true}\n"
    refute_includes plan("--aliases").keys, "manifest.webmanifest"
  end

  def test_a_site_file_at_the_path_is_never_overwritten
    config ON
    file "manifest.webmanifest", "{\"name\": \"Mine\"}\n"
    _, e, code = stubs("--pwa", "--write")
    assert_equal 3, code
    assert_match(/manifest\.webmanifest: the site's own file/, e)
    assert_equal "{\"name\": \"Mine\"}\n", read("manifest.webmanifest")
  end

  def test_an_offline_page_per_full_language
    config "modootoday:\n  languages: [en, ko, pt-BR]\n  full_languages: [ko, pt-BR]\n  pwa: {enabled: true}\n"
    assert_equal %w[manifest.webmanifest offline.ko.md offline.md offline.pt-BR.md sw.js], plan("--pwa").keys.sort
    stubs("--pwa", "--write")
    assert_equal "---\nlayout: pages/offline\nlang: pt-BR\npermalink: /pt-BR/offline/\nsitemap: false\nsearch: false\ntwin: false\n---\n", read("offline.pt-BR.md")
    assert_equal({}, plan("--twins").select { |k, _| k.start_with?("offline") }, "no twin for the offline pages")
    config "modootoday:\n  full_languages: [\"../x\"]\n  pwa: {enabled: true}\n"
    _, e, code = stubs("--pwa")
    assert_equal 3, code
    assert_match(/full_languages: "\.\.\/x" is not a language code/, e)
  end

  def test_under_a_directory_each_stub_names_its_root_path
    config "modootoday:\n  full_languages: [ko]\n  pwa: {enabled: true}\n"
    wanted = Modootoday::Stubs::Pwa.new(Modootoday::Stubs::Source.new(@src), dir: "generated").wanted
    assert_equal %w[generated/manifest.webmanifest generated/offline.ko.md generated/offline.md generated/sw.js], wanted.keys.sort
    assert_equal "---\nlayout: null\npath: sw.js\npermalink: /sw.js\nsitemap: false\n---\n{% include modootoday/pwa/sw.js %}\n", wanted["generated/sw.js"]
    assert_includes wanted["generated/offline.ko.md"], "lang: ko\npath: offline.ko.md\npermalink: /ko/offline/\n"
  end

  def test_kill_keeps_writing_the_stubs
    config "modootoday:\n  pwa: {enabled: kill}\n"
    assert_equal %w[manifest.webmanifest offline.md sw.js], plan("--pwa").keys.sort
  end

  def test_a_site_offline_page_is_never_overwritten
    config ON
    file "offline.md", "---\ntitle: Offline\n---\n# Mine\n"
    _, e, code = stubs("--pwa", "--write")
    assert_equal 3, code
    assert_match(/offline\.md: the site.s own file/, e)
  end

  def test_needs_the_pwa_enabled
    ["", "modootoday:\n  pwa: {enabled: false}\n", "modootoday:\n  pwa: true\n"].each do |yaml|
      config yaml
      _, e, code = stubs("--pwa")
      assert_equal 2, code, yaml
      assert_match(/--pwa: set modootoday\.pwa\.enabled: true/, e)
    end
  end

  def test_the_pwa_fixture_site_holds_current_stubs
    fixture = File.expand_path("../fixtures/sites/pwa", __dir__)
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, STUBS, fixture, "--pwa", "--check")
    assert_equal 0, st.exitstatus, o + e
    assert_match(/up to date/, o + e)
  end

  def test_help_lists_the_option
    o, = stubs("--help")
    assert_match(/--pwa\s+the files modootoday\.pwa needs/, o)
  end
end
