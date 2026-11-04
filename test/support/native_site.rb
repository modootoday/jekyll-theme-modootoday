# frozen_string_literal: true
# The fixture sites of plain Jekyll shapes (test/fixtures/sites/): a site as `jekyll new` writes it, with only its
# theme line changed, and nested layout paths. jekyll-feed is left out of plugins on a bundle without it.
require_relative "layout_site"

module NativeSite
  include LayoutSite

  FIXTURES = File.expand_path("../fixtures/sites", __dir__)
  MINIMA = File.join(FIXTURES, "minima-shaped")
  NESTED = File.join(FIXTURES, "nested-layouts")
  GH_PAGES = Gem.loaded_specs.key?("github-pages")

  def plugins_yaml = Gem.loaded_specs.key?("jekyll-feed") ? "" : "plugins: []\n"

  # The minima-shaped site plus pages, files (path => text) and settings, with pretty URLs so pages read as
  # <name>/index.html; returns [src, site].
  def build_minima(dir, pages = {}, config: "", files: {})
    build_site(dir, pages, config: "permalink: pretty\n#{plugins_yaml}#{config}", from: MINIMA, files: files)
  end

  def post_html(site) = File.read(Dir.glob("#{site}/jekyll/update/**/welcome-to-jekyll.html").first)
end
