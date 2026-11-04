# frozen_string_literal: true
# Step L0 of the adoption ladder: a site exactly as `jekyll new` writes it (test/fixtures/sites/minima-shaped), with
# only its theme line changed, builds on the active bundle (github-pages 232 or Jekyll 4) and keeps what minima showed.
# CI runs it on both stacks (ci.yml) and on remote_theme (starters.yml).
require "minitest/autorun"
require "open3"
require "fileutils"
require "tmpdir"
require_relative "../support/native_site"

class MinimaShapedTest < Minitest::Test
  include NativeSite

  def build(dir)
    src = "#{dir}/src"
    FileUtils.cp_r(MINIMA, src)
    # minima reads author: {name, email}; jekyll new leaves it out, so it is the one added key.
    File.write("#{src}/_config.yml", File.read("#{src}/_config.yml") + "author: {name: Jane Doe, email: jane@example.com}\n")
    File.write("#{dir}/o.yml", plugins_yaml.empty? ? "{}\n" : plugins_yaml)
    out, st = Open3.capture2e(bundle_env, "bundle", "exec", "jekyll", "build", "-s", src, "-d", "#{dir}/s", "--config", "#{src}/_config.yml,#{dir}/o.yml", chdir: dir)
    assert st.success?, out
    [src, "#{dir}/s", out]
  end

  def test_jekyll_new_site_switches_theme_without_losing_anything
    Dir.mktmpdir do |d|
      src, site, log = build(d)
      refute_match(/Layout '[^']+' requested in .* does not exist/, log)
      home = File.read("#{site}/index.html")
      assert_match(%r{<nav class="mt-nav"[^>]*><ul>\s*<li><a href="/about/"[^>]*>About</a>}, home, "auto nav lists the titled page")
      assert_includes home, 'class="mt-blog mt-home-posts"'
      assert_includes home, "Welcome to Jekyll!"
      assert_includes File.read("#{site}/about/index.html"), '<article class="mt-doc">'
      assert_includes File.read("#{site}/404.html"), '<article class="mt-doc">'
      post = post_html(site)
      assert_includes post, '<span class="mt-post-author">Jane Doe</span>'
      assert_includes post, '<time datetime="2026-01-05T10:00:00+00:00">'
      out, st = check(src, site)
      assert st.success?, out
    end
  end
end
