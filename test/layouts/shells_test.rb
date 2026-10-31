# frozen_string_literal: true
# Page-shell layouts: chrome switch, optional bundle link and Liquid-only output (built docs site).
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class PagesLayoutsTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  LAYOUTS = %w[minimal wide home error redirect search].freeze

  def read(f) = File.read(File.join(ROOT, f))

  def test_every_shell_ships_and_needs_no_new_script
    LAYOUTS.each do |l|
      src = read("_layouts/#{l}.html")
      refute_match(/<script(?! type="application\/ld\+json")/, src, "#{l}: no new JavaScript")
    end
  end

  def test_bundle_is_opt_in_per_layout
    %w[minimal wide].each { |l| assert_match(/^mt_bundle: pages$/, read("_layouts/#{l}.html")) }
    assert_match(/modootoday-' \| append: _b/, read("_includes/modootoday/stylesheets.html"))
    assert File.exist?(File.join(ROOT, "assets/css/modootoday-pages.scss"))
  end

  def test_minimal_turns_chrome_off
    assert_match(/^mt_chrome: false$/, read("_layouts/minimal.html"))
    assert_match(/layout\.mt_chrome == false/, read("_layouts/default.html"))
  end

  def test_redirect_is_script_free_and_noindex
    src = read("_layouts/redirect.html")
    assert_includes src, 'http-equiv="refresh"'
    assert_includes src, 'name="robots" content="noindex"'
    assert_includes src, 'rel="canonical"'
  end

  # The built redirect stubs carry the target in the refresh, the canonical and the link: from redirect_to front
  # matter, from redirect: {to:} (as jekyll-redirect-from 0.16 sets it), and from redirect_from when the plugin loads
  # (the plugin also turns redirect_to into a full redirect.to).
  def test_built_redirects_have_targets
    plugin = begin; require "jekyll-redirect-from"; true; rescue LoadError; false; end
    Dir.mktmpdir do |dir|
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes i18n].map { |d| File.join(ROOT, d) }.select { |d| File.exist?(d) }, src)
      File.write(File.join(src, "_config.yml"), "url: https://ex.test\nbaseurl: /b\npermalink: pretty\n" + (plugin ? "plugins: [jekyll-redirect-from]\n" : ""))
      File.write(File.join(src, "old-a.md"), "---\nlayout: redirect\nredirect_to: /new/\n---\n")
      File.write(File.join(src, "old-b.md"), "---\nlayout: redirect\nredirect: {to: https://ex.test/b/new/}\n---\n")
      File.write(File.join(src, "new.md"), "---\nlayout: minimal\nredirect_from: [/old-c/]\n---\nNew\n")
      Jekyll.logger.log_level = :error
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      pages = { "old-a" => plugin ? "https://ex.test/b/new/" : "/b/new/", "old-b" => "https://ex.test/b/new/" }
      pages["old-c"] = "https://ex.test/b/new/" if plugin
      pages.each do |name, to|
        html = File.read(File.join(dir, "_site", name, "index.html"))
        assert_includes html, %(content="0; url=#{to}"), name
        assert_includes html, %(<a href="#{to}">), name
        assert_match %r{rel="canonical" href="https://ex\.test/b/new/"}, html, name
      end
    end
  end

  def test_error_keys_exist_in_registry
    en = read("i18n/en.yml")
    %w[not_found not_found_text gone gone_text error error_text home moved moved_link search_hint].each { |k| assert_match(/^  #{k}: /, en) }
  end
end
