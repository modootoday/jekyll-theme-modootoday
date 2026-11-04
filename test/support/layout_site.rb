# frozen_string_literal: true
# Builds a starter site (the docs starter unless named, or a fixture site) plus extra pages (name => front matter + body)
# with a url, for layout build tests.
require "tmpdir"
require "fileutils"
require "open3"
require "json"
require "yaml"
require "date"
require_relative "starters"

module LayoutSite
  ROOT = File.expand_path("../..", __dir__)

  # from: a site folder to start from instead of a starter (test/fixtures/sites/<name>); files: other files (path => text);
  # url: "" builds as a jekyll new site does.
  def build_site(dir, pages, config: "", env: {}, starter: "docs", from: nil, files: {}, url: "https://example.org")
    src = "#{dir}/src"
    FileUtils.cp_r(from || Starters::Sources.path(starter), src)
    FileUtils.rm_rf(["#{src}/_site", "#{src}/.jekyll-cache"])
    pages.to_h { |n, (fm, body)| [n, "---\n#{fm}---\n#{body || "Body text.\n"}"] }.merge(files).each do |n, text|
      FileUtils.mkdir_p(File.dirname("#{src}/#{n}"))
      File.write("#{src}/#{n}", text)
    end
    merge_config("#{src}/_config.yml", config) unless config.empty?
    File.write("#{dir}/o.yml", "url: #{url.inspect}\n")
    out, st = Open3.capture2e(bundle_env.merge(env), "bundle", "exec", "jekyll", "build", "-q", "-s", src, "-d", "#{dir}/s",
                              "--config", "#{src}/_config.yml,#{dir}/o.yml", chdir: dir)
    assert st.success?, out
    [src, "#{dir}/s"]
  end

  # Jekyll 3 outside safe mode reads ./_layouts of the working directory before the site's, so builds run from the
  # temporary folder (as a user runs them from the site), with the active bundle named explicitly.
  def bundle_env = { "BUNDLE_GEMFILE" => ENV["BUNDLE_GEMFILE"] || File.join(ROOT, "Gemfile") }

  # Deep-merges YAML into the copied _config.yml, so the checker reads the same settings as the build.
  def merge_config(file, yaml)
    deep = ->(a, b) { a.merge(b) { |_, x, y| x.is_a?(Hash) && y.is_a?(Hash) ? deep.(x, y) : y } }
    File.write(file, YAML.dump(deep.(YAML.safe_load(File.read(file), permitted_classes: [Date, Time]) || {}, YAML.safe_load(yaml))))
  end

  def html(site, name) = File.read("#{site}/#{name.delete_suffix('.md')}/index.html")

  def graph(site, name) = JSON.parse(html(site, name)[%r{<script type="application/ld\+json">(.*?)</script>}m, 1])["@graph"]

  def main_node(site, name) = graph(site, name).find { |n| n["@id"].to_s.end_with?("#main") }

  def check(src, site, *flags)
    Open3.capture2e(RbConfig.ruby, "#{ROOT}/exe/modootoday-check", src, site, *flags, chdir: ROOT)
  end
end
