# frozen_string_literal: true
# Page-shell layouts: chrome switch, optional bundle link and Liquid-only output (built docs site).
require "minitest/autorun"

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

  def test_error_keys_exist_in_registry
    en = read("i18n/en.yml")
    %w[not_found not_found_text gone gone_text error error_text home moved moved_link search_hint].each { |k| assert_match(/^  #{k}: /, en) }
  end
end
