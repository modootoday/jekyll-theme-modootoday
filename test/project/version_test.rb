# frozen_string_literal: true
# One version everywhere: gemspec, CHANGELOG, README (en/ko), docs install pages and the example config.
require "minitest/autorun"

class VersionTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  def read(f) = File.read(File.join(ROOT, f))
  def version = read("jekyll-theme-modootoday.gemspec")[/spec\.version\s*=\s*"([^"]+)"/, 1]

  def test_changelog_has_the_gemspec_version
    assert_match(/^\d+\.\d+\.\d+\z/, version)
    assert_match(/^## \[#{Regexp.escape(version)}\]/, read("CHANGELOG.md"))
    assert_match(/^\[#{Regexp.escape(version)}\]: /, read("CHANGELOG.md"))
  end

  def test_install_snippets_pin_the_current_version
    minor = version.split(".")[0, 2].join(".")
    files = %w[README.md README.ko.md docs/guides/install.md docs/ko/guides/install.md docs/index.md docs/ko/index.md docs/ja/guides/install.md docs/ja/index.md example/_config.yml]
    files.each do |f|
      t = read(f)
      t.scan(/jekyll-theme-modootoday", "~> ([\d.]+)"/).flatten.each { |v| assert_equal minor, v, "#{f}: gem constraint" }
      t.scan(/jekyll-theme-modootoday@v([\d.]+)/).flatten.each { |v| assert_equal version, v, "#{f}: remote_theme tag" }
      t.scan(/jekyll-theme-modootoday -v '~> ([\d.]+)'/).flatten.each { |v| assert_equal minor, v, "#{f}: gem install constraint" }
      t.scan(%r{tags/v([\d.]+)\.tar\.gz|jekyll-theme-modootoday-([\d.]+)/exe}).flatten.compact.each { |v| assert_equal version, v, "#{f}: source tarball" }
    end
    assert_includes read("README.md"), %("~> #{minor}")
    assert_includes read("README.md"), "@v#{version}"
  end

  def test_docs_name_no_unreleased_version
    Dir[File.join(ROOT, "{README.md,README.ko.md,docs/**/*.md}")].each do |f|
      t = File.read(f)
      refute_match(/`since:[^`\s]/, t, "#{f}: since badge before 1.1")
      refute_match(/v0\.\d\.\d|~> 0\.\d/, t, "#{f}: unreleased 0.x version")
    end
  end

  # qa/docs/structure.rb bans "2.0" in user docs, but not inside a longer version or name such as v1.2.0 or v2.0+ (same word boundary as before).
  def test_banned_two_point_oh_skips_version_numbers
    re = eval(read("qa/docs/structure.rb")[/^BANNED = (\[.*\])\.freeze$/, 1]).find { |r| r.source.include?("2\\.0") }
    %w[2.0 (2.0) 2.0.1].each { |t| assert_match re, "see #{t} here", t }
    %w[@v1.2.0 1.2.0 12.0 v3.2.0 v2.0+].each { |t| refute_match re, "see #{t} here", t }
  end
end
