# frozen_string_literal: true
# One version everywhere: gemspec, CHANGELOG, README (en/ko), docs install pages and the version include.
# The starters take it from the gemspec when they are rendered (test/starters/render_test.rb).
require "minitest/autorun"
require_relative "../../script/release/pins"

class VersionTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  def read(f) = File.read(File.join(ROOT, f))
  def version = read("jekyll-theme-modootoday.gemspec")[/spec\.version\s*=\s*"([^"]+)"/, 1]

  def test_changelog_has_the_gemspec_version
    assert_match(/^\d+\.\d+\.\d+\z/, version)
    assert_match(/^## \[#{Regexp.escape(version)}\]/, read("CHANGELOG.md"))
    assert_match(/^\[#{Regexp.escape(version)}\]: /, read("CHANGELOG.md"))
  end

  def test_version_include_matches_the_gemspec
    assert_includes read("_includes/modootoday/version.html"), %({%- assign mt_version = "#{version}" -%}), "run script/version-include"
    assert system("ruby", File.join(ROOT, "script/version-include"), "--check", err: File::NULL), "run script/version-include"
  end

  def test_install_snippets_pin_the_current_version
    assert_equal version, Release::Pins.version
    Release::Pins::FILES.each { |f| assert_empty Release::Pins.mismatches(read(f), version), "#{f}: run script/release-prep" }
    assert_includes read("README.md"), %("~> #{Release::Pins.minor(version)}")
    assert_includes read("README.md"), "@v#{version}"
  end

  def test_pins_are_rewritten_to_a_new_version
    text = %(gem "jekyll-theme-modootoday", "~> 1.6"\nremote_theme: o/jekyll-theme-modootoday@v1.6.0\n) +
           %(gem install jekyll-theme-modootoday -v '~> 1.6'\n/archive/refs/tags/v1.6.0.tar.gz\njekyll-theme-modootoday-1.6.0/exe/x\n)
    out = Release::Pins.rewrite(text, "1.7.0")
    assert_empty Release::Pins.mismatches(out, "1.7.0")
    assert_equal 5, Release::Pins.mismatches(text, "1.7.0").size
  end

  def test_docs_name_no_unreleased_version
    Dir[File.join(ROOT, "{README.md,README.ko.md,docs/**/*.md}")].each do |f|
      t = File.read(f)
      refute_match(/`since:[^`\s]/, t, "#{f}: since badge before 1.1")
      refute_match(/v0\.\d\.\d|~> 0\.\d/, t, "#{f}: unreleased 0.x version")
    end
  end

  # test/system/docs/structure.rb bans "2.0" in user docs, but not inside a longer version or name such as v1.2.0 or v2.0+ (same word boundary as before).
  def test_banned_two_point_oh_skips_version_numbers
    re = eval(read("test/system/docs/structure.rb")[/^BANNED = (\[.*\])\.freeze$/, 1]).find { |r| r.source.include?("2\\.0") }
    %w[2.0 (2.0) 2.0.1].each { |t| assert_match re, "see #{t} here", t }
    %w[@v1.2.0 1.2.0 12.0 v3.2.0 v2.0+].each { |t| refute_match re, "see #{t} here", t }
  end
end
