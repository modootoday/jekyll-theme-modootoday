# frozen_string_literal: true
require "minitest/autorun"
require "yaml"
require_relative "../support/starters"
require_relative "../support/layout_site"

# Starter chrome, from example/starters.yml: every starter home ends in a footer and not in the docs pager, and a
# starter with more than one language shows the language switcher on each language home.
class StarterChromeTest < Minitest::Test
  include LayoutSite

  def manifest = Starters::Sources.render.manifest

  def built
    @built ||= manifest.starters.to_h do |s|
      dir = Dir.mktmpdir
      Minitest.after_run { FileUtils.rm_rf(dir) }
      [s, build_site(dir, {}, starter: s.name).last]
    end
  end

  def home(site, lang = nil) = File.read(File.join(site, lang.to_s, "index.html"))

  def test_every_home_has_a_footer_and_no_docs_pager
    built.each do |s, site|
      h = home(site)
      assert_match(%r{<footer class="mt-footer">.*?class="mt-footer-cols"}m, h, "#{s.name}: footer columns")
      next if s.name == "docs"

      refute_includes h, '<nav class="mt-pagination"', "#{s.name}: the home page ends in the docs pager"
    end
  end

  def test_each_language_home_has_the_switcher
    built.each do |s, site|
      next if s.languages.size < 2

      cfg = YAML.safe_load(File.read("#{s.dir}/_config.yml"))["modootoday"]
      assert_equal s.languages, cfg["languages"], "#{s.name}: modootoday.languages"
      ([nil] + s.languages.drop(1)).each do |l|
        assert_includes home(site, l), 'class="mt-lang', "#{s.name}: language switcher on the #{l || s.languages.first} home"
      end
    end
  end
end
