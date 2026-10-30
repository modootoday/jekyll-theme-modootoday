# frozen_string_literal: true
# Builds the example site plus extra pages (name => front matter + body) with a url, for layout build tests.
require "tmpdir"
require "fileutils"
require "open3"
require "json"

module LayoutSite
  ROOT = File.expand_path("../..", __dir__)

  def build_site(dir, pages)
    src = "#{dir}/src"
    FileUtils.cp_r("#{ROOT}/example", src)
    pages.each do |n, (fm, body)|
      FileUtils.mkdir_p(File.dirname("#{src}/#{n}"))
      File.write("#{src}/#{n}", "---\n#{fm}---\n#{body || "Body text.\n"}")
    end
    File.write("#{dir}/o.yml", "url: https://example.org\n")
    out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", src, "-d", "#{dir}/s",
                              "--config", "#{src}/_config.yml,#{dir}/o.yml", chdir: ROOT)
    assert st.success?, out
    [src, "#{dir}/s"]
  end

  def html(site, name) = File.read("#{site}/#{name.delete_suffix('.md')}/index.html")

  def graph(site, name) = JSON.parse(html(site, name)[%r{<script type="application/ld\+json">(.*?)</script>}m, 1])["@graph"]

  def main_node(site, name) = graph(site, name).find { |n| n["@id"].to_s.end_with?("#main") }

  def check(src, site)
    Open3.capture2e(RbConfig.ruby, "#{ROOT}/exe/modootoday-check", src, site, chdir: ROOT)
  end
end
