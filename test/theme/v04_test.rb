# frozen_string_literal: true
# v0.4: timeline, kbd, search (index + header box), post layout, and tokens.json consistency with the built CSS.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "json"
require "jekyll"
load File.expand_path("../../script/tokens-json", __dir__)

class V04Test < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)

  def self.build(extra = "")
    (@b ||= {})[extra] ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(File.join(src, "_posts"))
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: Site\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\nsass: {silence_deprecations: [import, global-builtin]}\n" \
                                                "defaults: [{scope: {path: ''}, values: {layout: doc}}, {scope: {type: posts}, values: {layout: post}}]\n#{extra}")
      File.write(File.join(src, "index.md"), <<~MD)
        ---
        title: Home
        sections: [{c: timeline, name: tl}]
        ---
        # Home

        Press `kbd:Ctrl+K` or `kbd:a b`.

        ## History

        ### 2026-01

        Started.
      MD
      File.write(File.join(src, "search.json"), "---\nlayout: null\n---\n{% include modootoday/search.json %}\n")
      File.write(File.join(src, "_posts/2026-10-01-hello.md"), "---\ntitle: Hello\nauthor: Kim\ntags: [news]\n---\n# Hello\n\nBody text.\n")
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      File.join(dir, "_site")
    end
  end

  def site(extra = "") = self.class.build(extra)
  def read(rel, extra = "") = File.read(File.join(site(extra), rel))

  def test_kbd
    h = read("index.html")
    assert_includes h, '<kbd class="mt-kbd"><kbd>Ctrl</kbd>+<kbd>K</kbd></kbd>'
    assert_includes h, ">kbd:a b</code>"
  end

  def test_timeline_section
    assert_includes read("index.html"), 'data-c="timeline"'
  end

  def test_search_index_and_box
    idx = JSON.parse(read("search.json"))
    assert(idx.any? { _1["title"] == "Home" && _1["url"] == "/" })
    assert(idx.any? { _1["title"] == "Hello" && _1["text"].include?("Body text") })
    h = read("index.html")
    assert_includes h, 'class="mt-search" role="search" data-index="/search.json"'
    assert_includes h, "search.js"
  end

  def test_post_layout
    h = read("2026/10/01/hello/index.html")
    assert_match(%r{<p class="mt-post-meta"><time datetime="2026-10-01T[^"]+">2026-10-01</time> · <span class="mt-post-author">Kim</span> <span class="mt-badge mt-badge-tag"[^>]*>news</span>}, h)
    assert_includes h, '<article class="mt-doc md-doc">'
  end

  def test_disabled
    h = read("index.html", "modootoday: {components: [callout]}\n")
    %w[mt-kbd mt-search search.js].each { refute_includes h, _1 }
  end

  def test_search_js_size_budget
    require "zlib"
    js = File.read(File.join(ROOT, "assets/js/modootoday/search.js"))
    assert_operator Zlib::Deflate.deflate(js, 9).bytesize, :<, 1024, "search.js must stay under 1 KB compressed"
  end

  def test_tokens_json_matches_css
    tokens = build
    css = read("assets/css/modootoday.css")
    root = css[/:root\s*\{(.*?)\}/m, 1]
    dark = css[/:root\[data-theme="?dark"?\]\s*\{(.*?)\}/m, 1]
    tokens["primitive"].each do |k, t|
      v = root[/--mt-p-#{Regexp.escape(k)}:\s*([^;]+)/, 1] or flunk("--mt-p-#{k} missing in CSS")
      assert_equal t["$value"].downcase, v.strip.downcase, k if t["$type"] == "color"
    end
    %w[base light].each { |g| tokens[g].each_key { |k| assert_match(/--mt-#{Regexp.escape(k)}:/, root, "--mt-#{k}") } }
    tokens["dark"].each do |k, t|
      exp = t["$value"].sub(/\A\{primitive\.(.+)\}\z/, 'var(--mt-p-\1)')
      assert_match(/--mt-#{Regexp.escape(k)}:\s*#{Regexp.escape(exp)}/, dark, "dark #{k}")
    end
  end
end
