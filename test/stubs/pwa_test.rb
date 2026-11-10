# frozen_string_literal: true
# modootoday-stubs --pwa: the manifest stub, preview, write and check, never pruned, a site file at the path, the config gate.
require_relative "stubs_case"
require_relative "../../lib/modootoday/stubs"

class StubsPwaTest < StubsCase
  ON = "modootoday:\n  pwa: {enabled: true}\n"

  def test_preview_write_and_check
    config ON
    assert_equal({ "manifest.webmanifest" => "create" }, plan("--pwa"))
    refute exist?("manifest.webmanifest"), "preview writes nothing"
    assert_equal 1, stubs("--pwa", "--check")[2]
    stubs("--pwa", "--write")
    assert_equal Modootoday::Stubs::Pwa::FILES["manifest.webmanifest"], read("manifest.webmanifest")
    assert_equal "---\nlayout: null\npermalink: /manifest.webmanifest\nsitemap: false\n---\n{% include modootoday/pwa/manifest.json %}\n", read("manifest.webmanifest")
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

  def test_needs_the_pwa_enabled
    ["", "modootoday:\n  pwa: {enabled: false}\n", "modootoday:\n  pwa: true\n"].each do |yaml|
      config yaml
      _, e, code = stubs("--pwa")
      assert_equal 2, code, yaml
      assert_match(/--pwa: set modootoday\.pwa\.enabled: true/, e)
    end
  end

  def test_help_lists_the_option
    o, = stubs("--help")
    assert_match(/--pwa\s+the files modootoday\.pwa needs/, o)
  end
end
