# frozen_string_literal: true
require "minitest/autorun"
require "yaml"
require_relative "../support/starters"

# example/starters.yml and the source folders it names: plain folders hold only what a person writes (a published
# starter's gitlink also holds the files the theme renders; test/starters/published_test.rb).
class StarterSourcesTest < Minitest::Test
  def manifest = Starters::Sources.render.manifest

  def test_every_starter_is_listed_once_and_published_to_its_own_repo
    assert_equal %w[docs blog landing], manifest.starters.map(&:name)
    assert_equal manifest.starters.size, manifest.starters.map(&:repo).uniq.size
    folders = Dir.children(File.dirname(manifest.path)).select { |f| File.directory?(File.join(File.dirname(manifest.path), f)) }
    assert_equal manifest.starters.map(&:name).sort, folders.sort, "every folder in example/ is a starter"
  end

  def test_sources_hold_no_generated_files
    manifest.starters.reject(&:published).each do |s|
      files = Starters::Render.files(s.dir)
      assert_empty files.grep(/\.md\.txt\z/), "#{s.name}: stubs are written at render time"
      next unless YAML.safe_load(File.read("#{s.dir}/_config.yml")).dig("modootoday", "records")

      plan = Modootoday::Stubs::Plan.new(Modootoday::Stubs::Source.new(s.dir), [:records])
      assert_equal ["missing"], plan.changes.map(&:reason).uniq, "#{s.name}: record pages are written at render time"
    end
  end

  # A site catalog that repeats a theme string would freeze it; a starter keeps only what it changes.
  def test_site_catalogs_hold_only_what_the_theme_lacks
    leaves = ->(h, pre = nil) { h.is_a?(Hash) ? h.flat_map { |k, v| leaves.(v, [pre, k].compact.join(".")) } : [[pre, h]] }
    manifest.starters.each do |s|
      Dir.glob("#{s.dir}/_data/i18n/*.yml").each do |f|
        theme = leaves.(YAML.safe_load(File.read("#{Starters::Sources::ROOT}/i18n/#{File.basename(f)}"))).to_h
        same = leaves.(YAML.safe_load(File.read(f))).select { |k, v| theme[k] == v }.map(&:first)
        assert_empty same, "#{s.name}/_data/i18n/#{File.basename(f)} repeats theme strings"
      end
    end
  end

  def test_languages_are_the_config_default_and_language_folders
    manifest.starters.each do |s|
      cfg = YAML.safe_load(File.read("#{s.dir}/_config.yml"))
      assert_equal s.languages.first, cfg["lang"], s.name
      s.languages.drop(1).each { |l| assert File.directory?("#{s.dir}/#{l}"), "#{s.name}: #{l}/ folder (directory mode)" }
    end
  end

  def test_rendered_sites_have_their_stubs
    docs = Starters::Sources.path("docs")
    %w[index.md.txt ko/guide.md.txt ja/index.md.txt plugins/lantern.md].each { |f| assert File.file?("#{docs}/#{f}"), f }
    assert File.file?("#{Starters::Sources.path("blog")}/authors/alex.md.txt")
    assert File.file?("#{Starters::Sources.path("landing")}/pricing.md.txt")
  end
end
