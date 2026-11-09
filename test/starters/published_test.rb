# frozen_string_literal: true
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "../../script/starters/render"

# Published starters are gitlinks at their manifest path (adr:modootoday/20261104171142): .gitmodules follows the
# manifest, the gem ships none of example/, and a published tree renders back from its own content at its pin.
class StarterPublishedTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  THEME = Starters::Theme.new(ROOT)
  TINY = Starters::Manifest.new(File.join(ROOT, "test/fixtures/starters/starters.yml"), THEME)
  Fake = Struct.new(:starters)

  def manifest = @manifest ||= Starters::Manifest.new(File.join(ROOT, "example/starters.yml"), THEME)

  def gitmodules
    out = IO.popen(["git", "-C", ROOT, "config", "-f", ".gitmodules", "--get-regexp", '^submodule\..*\.(path|url)$'], &:read)
    out.lines.each_with_object(Hash.new { |h, k| h[k] = {} }) do |l, h|
      key, value = l.split(" ", 2)
      name, field = key.delete_prefix("submodule.").rpartition(".").values_at(0, 2)
      h[name][field] = value.chomp
    end
  end

  def test_gitmodules_entries_are_the_published_manifest_rows
    entries = gitmodules.values.to_h { |e| [e["path"], e["url"]] }
    published = manifest.starters.select(&:published)
    refute_empty published
    assert_equal published.to_h { |s| [s.path, s.submodule_url] }, entries
    assert(published.all? { |s| s.path == "example/#{s.name}" }, "a published starter keeps its folder path")
  end

  def test_the_gem_ships_no_example_path
    spec = Gem::Specification.load(File.join(ROOT, "jekyll-theme-modootoday.gemspec"))
    assert_empty spec.files.grep(%r{\Aexample/})
  end

  def test_pins_are_released_versions
    errors, = Starters::Render.new(manifest, THEME).pins
    assert_empty errors
    assert_includes THEME.released, "1.6.0"
    refute_includes THEME.released, "9.9.9"
  end

  def with_published
    Dir.mktmpdir do |d|
      tiny = TINY.fetch("tiny").dup.tap { |s| s.path = "example/tiny" }
      Starters::Render.new(TINY, THEME).one(tiny, "github-pages", "#{d}/tiny")
      yield tiny.dup.tap { |s| s.dir, s.published = "#{d}/tiny", true }, d
    end
  end

  def test_content_is_the_source_folder_and_renders_back_unchanged
    with_published do |s, d|
      Starters::Published.new(s, THEME).extract("#{d}/content", Starters::Render::OWNED)
      source = "#{ROOT}/test/fixtures/starters/tiny"
      assert_equal File.read("#{source}/_config.yml"), File.read("#{d}/content/_config.yml")
      assert_empty Starters::Render.files("#{d}/content") - Starters::Render.files(source) - ["ko/index.md.txt", "index.md.txt"]
      assert_empty Starters::Render.new(Fake.new([s]), THEME).drift("#{d}/none").reject { |l| l.start_with?("github-pages/", "jekyll4/") }
    end
  end

  def test_drift_and_publish_name_the_published_files
    with_published do |s, _|
      render = Starters::Render.new(Fake.new([s]), THEME)
      File.write("#{s.dir}/README.md", "edited\n")
      File.write("#{s.dir}/.git", "gitdir: ../.git/modules/tiny\n")
      assert_includes render.drift("#{s.dir}/../pkg"), "example/tiny/README.md: differs"
      assert_equal ["README.md: differs"], render.publish(s)
      assert_empty render.drift("#{s.dir}/../pkg").grep(%r{\Aexample/})
      assert File.file?("#{s.dir}/.git"), "publish leaves the gitlink's .git file alone"
    end
  end

  def test_a_pin_that_is_not_released_fails_and_an_older_one_warns
    with_published do |s, _|
      File.write("#{s.dir}/_config.yml", File.read("#{s.dir}/_config.yml").sub("@v#{THEME.version}", "@v9.9.9"))
      errors, = Starters::Render.new(Fake.new([s]), THEME).pins
      assert_equal ["example/tiny: remote_theme pins v9.9.9, which is not a released version"], errors
      File.write("#{s.dir}/_config.yml", File.read("#{s.dir}/_config.yml").sub("@v9.9.9", "@v1.5.0"))
      errors, warns = Starters::Render.new(Fake.new([s]), THEME).pins
      assert_empty errors
      assert_match(/pins v1\.5\.0, behind #{Regexp.escape(THEME.version)}/, warns.join)
    end
  end

  def test_a_published_tree_must_pin_this_theme
    with_published do |s, _|
      File.write("#{s.dir}/_config.yml", File.read("#{s.dir}/_config.yml").sub(/^remote_theme: .*$/, "remote_theme: other/theme@v1.0.0"))
      assert_match(/pins remote_theme: #{THEME.repo}@vX\.Y\.Z/, assert_raises(Starters::ManifestError) { Starters::Published.new(s, THEME) }.message)
    end
  end
end
