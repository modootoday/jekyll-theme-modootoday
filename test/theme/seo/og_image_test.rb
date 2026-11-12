# frozen_string_literal: true
# Share image (meta/og-image.html): page image, hero image, then og_image as a map with alt and size, and JSON-LD naming
# the same image as Open Graph.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "json"
require "jekyll"

class OgImageTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)

  def self.site
    @site ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      cfg = { "title" => "Site", "lang" => "en", "url" => "https://example.org", "markdown" => "kramdown", "permalink" => "pretty",
              "sass" => { "silence_deprecations" => %w[import global-builtin] },
              "defaults" => [{ "scope" => { "path" => "" }, "values" => { "layout" => "doc" } }],
              "modootoday" => { "og_image" => { "path" => "/og.png", "alt" => "The site's card", "width" => 1200, "height" => 630 } } }
      File.write(File.join(src, "_config.yml"), cfg.to_yaml)
      File.write(File.join(src, "plain.md"), "---\ntitle: Plain\n---\n# Plain\n")
      File.write(File.join(src, "own.md"), "---\ntitle: Own\nimage: {path: /own.png, alt: A chart, width: 800, height: 400}\n---\n# Own\n")
      File.write(File.join(src, "named.md"), "---\ntitle: Named\nimage: /named.png\nimage_alt: A map\n---\n# Named\n")
      File.write(File.join(src, "hero.md"), "---\ntitle: Hero\nlayout: home\nhero: {title: Hero, image: {path: /hero.png, alt: A hero, width: 1600, height: 900}}\n---\n")
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      File.join(dir, "_site")
    end
  end

  def read(rel) = File.read(File.join(self.class.site, rel))

  def ld_image(h) = JSON.parse(h[%r{<script type="application/ld\+json">(.*?)</script>}m, 1])["@graph"].find { |n| n["@type"] == "WebPage" }&.dig("primaryImageOfPage", "url")

  def test_the_site_image_map_adds_alt_and_size
    h = read("plain/index.html")
    assert_includes h, '<meta property="og:image" content="https://example.org/og.png">'
    assert_includes h, '<meta property="og:image:width" content="1200">'
    assert_includes h, '<meta property="og:image:height" content="630">'
    assert_includes h, %(<meta property="og:image:alt" content="The site&#39;s card">)
    assert_includes h, %(<meta name="twitter:image:alt" content="The site&#39;s card">)
    assert_equal "https://example.org/og.png", ld_image(h)
  end

  def test_a_page_image_wins_with_its_own_alt
    h = read("own/index.html")
    assert_includes h, '<meta property="og:image" content="https://example.org/own.png">'
    assert_includes h, '<meta property="og:image:alt" content="A chart">'
    assert_includes h, '<meta property="og:image:width" content="800">'
    n = read("named/index.html")
    assert_includes n, '<meta property="og:image:alt" content="A map">'
    refute_includes n, "og:image:width", "a plain path has no size"
  end

  def test_the_hero_image_comes_before_the_site_image
    h = read("hero/index.html")
    assert_includes h, '<meta property="og:image" content="https://example.org/hero.png">'
    assert_includes h, '<meta property="og:image:alt" content="A hero">'
    assert_equal "https://example.org/hero.png", ld_image(h)
  end
end
