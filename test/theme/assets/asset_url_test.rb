# frozen_string_literal: true
# Versioned theme asset URLs (modootoday.asset_version): every theme CSS and JS tag takes its URL from
# modootoday/assets/url.html, so the ?v= query is on all of them or on none.
require "minitest/autorun"
require_relative "../../support/layout_site"

class AssetUrlTest < Minitest::Test
  include LayoutSite

  INCLUDE = "_includes/modootoday/assets/url.html"
  PAGES = { "v/code.md" => ["title: C\n", "# C\n\n```sh\nrun\n```\n\n| a | b |\n|---|---|\n| 1 | 2 |\n"] }.freeze
  TIME = "time: \"2026-01-01T00:00:00+00:00\"\n"
  THEME_TAG = %r{<link rel="stylesheet" href="/assets/(?:css/modootoday[^"]*)"|<script (?:type="module" )?src="/assets/(?:js/modootoday[^"]*)"}

  def version = File.read(File.join(ROOT, "jekyll-theme-modootoday.gemspec"))[/spec\.version\s*=\s*"([^"]+)"/, 1]

  def test_no_theme_asset_url_outside_the_url_include
    files = Dir.glob("{_layouts,_includes}/**/*.html", base: ROOT) - [INCLUDE]
    bad = files.flat_map do |f|
      File.readlines(File.join(ROOT, f)).each_with_index.filter_map do |l, i|
        "#{f}:#{i + 1}" if l.match?(%r{/assets/(css|js)/}) && l.match?(/\|\s*(relative|absolute)_url/)
      end
    end
    assert_empty bad, "take theme CSS and JS URLs from #{INCLUDE}"
  end

  def test_theme_version_by_default
    assert_versions("modootoday: {csp: strict}\n", "?v=#{version}", "chrome/theme-init.js")
  end

  def test_false_drops_the_query
    assert_versions("modootoday: {asset_version: false}\n", "")
  end

  # jekyll-github-metadata (GitHub Pages stack) reads JEKYLL_BUILD_REVISION, else git rev-parse in the theme
  # checkout; an empty value stands for a build with no revision.
  def test_build_falls_back_to_the_build_time
    assert_versions("modootoday: {asset_version: build}\n", "?v=#{version}-#{Time.utc(2026).to_i}",
                    env: { "JEKYLL_BUILD_REVISION" => "" })
  end

  # The Pages builder passes the commit as site.github.build_revision (jekyll-github-metadata); a config value stands in.
  def test_build_uses_the_short_commit
    assert_versions("github: {build_revision: \"0123456789abcdef\"}\nmodootoday: {asset_version: build}\n", "?v=#{version}-0123456")
  end

  private

  # Every theme stylesheet and script on a page with code, a table and the full chrome ends in the expected query.
  def assert_versions(config, query, also = nil, env: {})
    Dir.mktmpdir do |d|
      _, s = build_site(d, PAGES, config: TIME + config, env: env)
      h = html(s, "v/code.md")
      tags = h.scan(THEME_TAG)
      assert_operator tags.size, :>=, 6, h
      urls = tags.map { |t| t[/(?:href|src)="([^"]+)"/, 1] }
      urls.each { |u| assert_match(/\A[^?]+\.(css|js)#{Regexp.escape(query)}\z/, u) }
      assert(urls.any? { |u| u.include?(also) }, also) if also
    end
  end
end
