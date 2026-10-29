# frozen_string_literal: true
# modootoday-check rules for blog and news: settings, _data/authors.yml, listing and post front matter.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class BlogCheckTest < Minitest::Test
  CHECK = File.expand_path("../../exe/modootoday-check", __dir__)
  CLEAN_ENV = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze

  def setup
    @dir = Dir.mktmpdir
    @src = File.join(@dir, "src")
    FileUtils.mkdir_p([@src, File.join(@dir, "_site")])
  end

  def teardown = FileUtils.rm_rf(@dir)

  def write(name, text)
    path = File.join(@src, name)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, text)
  end

  def check
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, @src, File.join(@dir, "_site"))
    [o + e, st.exitstatus]
  end

  def test_valid_blog_site_passes
    write "_config.yml", "modootoday: {blog: {variant: grid, per_page: 5, related: 0, share: false}, news: {sections: [world]}}\n"
    write "_data/authors.yml", "kim: {name: Kim, url: 'https://example.com', page: /authors/kim/}\n"
    write "blog.md", "---\nlayout: blog\nvariant: magazine\n---\n# Blog\n"
    write "news.md", "---\nlayout: news\nnews_sections: [world]\n---\n# News\n"
    write "authors/kim.md", "---\nlayout: author\nauthor: kim\n---\n"
    write "_posts/2026-10-01-a.md", "---\ntitle: A\nlayout: news-article\nauthor: kim\nbreaking: true\nsources: [Agency]\n---\n# A\n"
    o, code = check
    assert_equal 0, code, o
  end

  def test_bad_settings_and_front_matter
    write "_config.yml", "modootoday: {blog: {variant: cards, per_page: ten, colour: red, share: maybe}, news: {sections: world}}\n"
    write "_data/authors.yml", "kim: {url: example.com}\n"
    write "blog.md", "---\nlayout: blog\nvariant: tiles\n---\n# Blog\n"
    write "authors/x.md", "---\nlayout: author\n---\n"
    write "_posts/2026-10-01-a.md", "---\ntitle: A\nauthor: lee\nbreaking: yes please\nsources: Agency\n---\n# A\n"
    o, code = check
    assert_equal 1, code, o
    ["modootoday.blog: unknown key 'colour'", "modootoday.blog.variant must be one of", "modootoday.blog.per_page must be a whole number",
     "modootoday.blog.share must be true or false", "modootoday.news must be a map", "_data/authors.yml: kim must be a map with name:",
     "blog.md: variant must be one of", "authors/x.md: layout: author needs author:", "breaking must be true or false",
     "sources must be a list", "author 'lee' is not in _data/authors.yml"].each { |m| assert_includes o, m }
  end
end
