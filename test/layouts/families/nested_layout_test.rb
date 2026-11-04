# frozen_string_literal: true
# Layouts in subfolders: _layouts/<group>/<name>.html is layout: group/name, from front matter and from defaults,
# chains into theme layouts, and the child's layout values win along the chain. Jekyll's LayoutReader reads the
# theme's _layouts the same way, which the second test pins without shipping a nested theme layout.
# CI runs this on github-pages 232 (Jekyll 3.10) and Jekyll 4 (ci.yml), and the fixture on remote_theme (starters.yml).
require "minitest/autorun"
require "jekyll"
require_relative "../../support/native_site"

class NestedLayoutTest < Minitest::Test
  include NativeSite

  def test_nested_site_layouts_build_and_chain_into_the_theme
    Dir.mktmpdir do |d|
      src, site = build_site(d, {}, from: NESTED)
      api = html(site, "api/get-user.md")
      assert_includes api, 'data-fixture-layout="endpoint" data-fixture-page="docs/endpoint"'
      assert_includes api, '<article class="mt-doc">'
      lesson = html(site, "learn/first.md")
      assert_includes lesson, 'data-fixture-layout="lesson" data-fixture-page="learn/lesson"', "defaults name a nested layout"
      assert_includes File.read("#{site}/index.html"), '<article class="mt-doc">', "layout: page is the doc layout"
      out, st = check(src, site)
      assert st.success?, out
    end
  end

  def test_theme_layouts_in_subfolders_are_read_by_path
    Dir.mktmpdir do |d|
      FileUtils.mkdir_p(["#{d}/theme/_layouts/docs", "#{d}/src/_layouts/docs"])
      File.write("#{d}/theme/_layouts/docs/endpoint.html", "---\nlayout: doc\n---\ntheme\n")
      File.write("#{d}/theme/_layouts/docs/release.html", "---\nlayout: doc\n---\ntheme\n")
      File.write("#{d}/src/_layouts/docs/endpoint.html", "---\nlayout: doc\n---\nsite\n")
      site = Jekyll::Site.new(Jekyll.configuration("source" => "#{d}/src", "destination" => "#{d}/out", "quiet" => true))
      theme = Jekyll::Theme.allocate
      theme.define_singleton_method(:root) { "#{d}/theme" }
      site.instance_variable_set(:@theme, theme)
      layouts = Jekyll::LayoutReader.new(site).read
      assert_equal "theme\n", layouts.fetch("docs/release").content
      assert_equal "site\n", layouts.fetch("docs/endpoint").content, "a site layout wins over the theme's"
    end
  end
end
