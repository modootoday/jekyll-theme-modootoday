# frozen_string_literal: true
# Docs-extra layouts (own bundle), legal (pages bundle) and resume (own print-first bundle): markup, structured data, checker.
require "minitest/autorun"
require_relative "site"
require "tmpdir"
require "fileutils"
require "jekyll"

class DocsExtraLayoutsTest < Minitest::Test
  include LayoutSite

  PAGES = {
    "r.md" => "title: R\nlayout: reference\nmembers: [{name: build, signature: 'build(opts)', text: Builds., since: '1.0'}, {name: serve, deprecated: Use dev.}]\n",
    "c.md" => "title: C\nlayout: changelog\nreleases: [{version: 1.1.0, date: 2026-10-01, added: ['A `x`'], fixed: [B]}]\n",
    "m.md" => "title: M\nlayout: roadmap\nitems: [{title: A, status: now}, {title: B, status: later, url: /b/}]\n",
    "g.md" => "title: G\nlayout: glossary\nterms: [{term: Zeta, text: Last.}, {term: Alpha, text: First.}]\n",
    "h.md" => "title: H\nlayout: hub\ncards: [{title: Guides, text: Start., url: /guides/}]\n",
    "co.md" => "title: Co\ndescription: Learn it.\nlayout: course\nlevel: Beginner\nmodules: [{title: Basics, lessons: [{title: One, minutes: 10}, {title: Two, minutes: 15}]}]\n",
    "b.md" => "title: B\nlayout: book\nauthor: Ada\nisbn: 978-0-00-000000-2\npages: 120\nchapters: [{title: Start, url: /s/}]\n",
    "l.md" => ["title: Terms\nlayout: legal\neffective: 2026-01-01\nupdated: 2026-10-01\n", "## Use\n\nText.\n\n## Ending\n\nText.\n"],
    "cv.md" => "title: CV\nlayout: resume\nname: Ada\nheadline: Engineer\nemail: ada@example.com\nlinks: [{label: GitHub, url: 'https://github.com/ada'}]\n" \
               "experience: [{role: Lead, org: Acme, start: 2024-01-01}, {role: Dev, org: Old, start: 2020-01-01, end: 2023-12-01}]\n" \
               "education: [{degree: BSc, school: Uni}]\nskills: [{group: Lang, items: [Ruby, Go]}]\n",
  }.freeze

  def test_build
    Dir.mktmpdir do |d|
      src, s = build_site(d, PAGES)
      %w[r c m g h co b].each { |n| assert_includes html(s, "#{n}.md"), "modootoday-docs-extra.css", n }
      assert_includes html(s, "l.md"), "modootoday-pages.css"
      assert_includes html(s, "l.md"), '<a href="#ending">Ending</a>'
      assert_includes html(s, "cv.md"), "modootoday-resume.css"
      assert_includes html(s, "r.md"), 'href="#serve"'
      assert_match(%r{<h3 class="mt-dx-cat mt-dx-cat-added">Added</h3>\s*<ul><li>A <code[^>]*>x</code></li>}, html(s, "c.md"))
      g = html(s, "g.md")[/<main.*/m]
      assert_operator g.index("Alpha"), :<, g.index("Zeta")
      assert_includes html(s, "co.md"), "25 min"
      assert_includes html(s, "cv.md"), "Present"
      assert_equal "TechArticle", main_node(s, "r.md")["@type"]
      assert_equal %w[Alpha Zeta].sort, main_node(s, "g.md")["hasDefinedTerm"].map { _1["name"] }.sort
      co = main_node(s, "co.md")
      assert_equal ["Course", "PT25M", "https://example.org/#publisher"], [co["@type"], co["timeRequired"], co["provider"]["@id"]]
      bk = main_node(s, "b.md")
      assert_equal ["Book", 120, "Chapter"], [bk["@type"], bk["numberOfPages"], bk["hasPart"][0]["@type"]]
      hub = graph(s, "h.md").find { _1["@type"] == "CollectionPage" }
      assert_equal "https://example.org/guides/", hub["hasPart"][0]["url"]
      assert graph(s, "l.md").find { _1["@type"] == "WebPage" }["datePublished"].start_with?("2026-01-01")
      p = graph(s, "cv.md").find { _1["@type"] == "ProfilePage" }["mainEntity"]
      assert_equal ["Acme", ["Uni"], %w[Ruby Go]], [p["worksFor"]["name"], p["alumniOf"].map { _1["name"] }, p["knowsAbout"]]
      out, st = check(src, s)
      assert st.success?, out
    end
  end

  def test_checker_contracts
    Dir.mktmpdir do |d|
      bad = { "m.md" => "title: M\nlayout: roadmap\nitems: [{title: A, status: soon}]\n",
              "g.md" => "title: G\nlayout: glossary\nterms: [{term: A, text: x}, {term: a, text: y}, {term: B}]\n",
              "c.md" => "title: C\nlayout: changelog\nreleases: [{version: '1', notes: [x]}]\n",
              "l.md" => "title: L\nlayout: legal\n",
              "b.md" => "title: B\nlayout: book\nisbn: '123'\n" }
      src, s = build_site(d, bad)
      out, st = check(src, s)
      refute st.success?
      ["items[0].status must be one of", "listed 2 times", "terms[2].text is required", "unknown keys notes", "effective must be a date", "isbn must be"].each { |m| assert_includes out, m }
    end
  end

  API = {
    "a.md" => "title: A\nlayout: reference\nsidebar: true\npackages_title: Crates\n" \
              "members: [{name: build, group: CLI}, {name: serve, group: CLI}, {name: Config, group: Library}]\n" \
              "packages: [{name: core, version: 1.4.0, text: The `core` crate., url: '#', links: [{label: Docs, url: '#'}]}, {name: cli}]\n",
    "p.md" => "title: P\nlayout: reference\npackages: [{name: core}]\n",
    "k.md" => ["title: K\nlayout: reference\npackages_compact: true\npackages_position: after\npackages: [{name: core, text: Hidden words.}]\n",
               "Intro.\n\n> [!TIP]\n> Pin the version.\n"],
  }.freeze

  def test_api_sidebar_and_package_table
    Dir.mktmpdir do |d|
      src, s = build_site(d, PAGES.merge(API))
      a = html(s, "a.md")
      assert_includes a, '<article aria-labelledby="mt-dx-title" class="mt-dx-api">'
      assert_match(%r{<nav class="mt-dx-side" aria-label="Contents"><ul><li><span class="mt-dx-side-h">CLI</span><ul><li><a href="#build">.*<li><span class="mt-dx-side-h">Library</span><ul><li><a href="#config">}m, a)
      refute_includes a, "mt-dx-toc"
      assert_includes a, "<caption>Crates</caption>"
      assert_includes a, '<th scope="col">Name</th><th scope="col">Version</th><th scope="col">Links</th>'
      assert_match(%r{<tr id="core"><th scope="row"><code><a href="#">core</a></code><span>The <code[^>]*>core</code> crate.</span></th>}, a)
      assert_includes a, '<td data-label="Version"><code>1.4.0</code></td>'
      assert_includes a, '<td data-label="Links"></td>'
      r = html(s, "r.md")
      refute_includes r, "mt-dx-api"
      refute_includes r, "mt-dx-pkgs"
      assert_includes r, '<nav class="mt-dx-toc"'
      refute_includes html(s, "p.md"), "mt-dx-member"
      assert_operator a.index('<div class="mt-dx-pkgs"><table>'), :<, a.index('<div class="mt-dx-body">')
      k = html(s, "k.md")
      refute_includes k, "Hidden words."
      assert_operator k.index("Intro."), :<, k.index('<div class="mt-dx-pkgs">')
      assert_match(/<blockquote class="mt-callout mt-callout-tip"/, k)
      refute_includes k, "[!TIP]"
      out, st = check(src, s)
      assert st.success?, out
    end
  end

  def test_api_checker_contracts
    Dir.mktmpdir do |d|
      bad = { "a.md" => "title: A\nlayout: reference\nsidebar: yes please\npackages_compact: 1\npackages_position: top\nmembers: [{name: x}]\npackages: [{version: 1}, {name: b, links: [{label: L}]}]\n" }
      src, s = build_site(d, bad)
      out, st = check(src, s)
      refute st.success?
      ["sidebar must be true or false", "packages_compact must be true or false", "packages_position must be one of", "packages[0] needs name", "packages[1].links[0].url is required"].each { |m| assert_includes out, m }
    end
  end
end


class TwinPackagesTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  PKGS = <<~YML
    packages:
      - {name: "core", version: "1.0", text: "Parse | render\\nthe model.", url: "https://example.org/core", links: [{label: "Docs", url: "/docs/"}, {label: "Src", url: "#"}]}
      - {name: "cli"}
  YML
  PAGES = {
    "plain" => "---\ntitle: Plain\nlayout: reference\n---\n# Plain\n\nBody.\n",
    "before" => "---\ntitle: Before\nlayout: reference\npackages_title: \"Pkgs\"\n#{PKGS}---\nBody.\n",
    "after" => "---\ntitle: After\nlayout: reference\npackages_position: after\npackages_compact: true\n#{PKGS}---\nBody.\n",
    "docpage" => "---\ntitle: Doc\nlayout: doc\n#{PKGS}---\nBody.\n"
  }.freeze

  def self.out
    @out ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: Site\nurl: https://example.org\nbaseurl: /b\npermalink: pretty\n")
      PAGES.each do |n, t|
        File.write(File.join(src, "#{n}.md"), t)
        File.write(File.join(src, "#{n}.md.txt"), "---\nlayout: twin\ntwin_of: #{n}.md\npermalink: /#{n}/index.md\n---\n")
      end
      File.write(File.join(src, "llms-full.txt"), "---\nlayout: llms-full\npermalink: /llms-full.txt\n---\n")
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      ->(p) { File.read(File.join(dir, "_site", p)) }
    end
  end

  def twin(n) = self.class.out.call("#{n}/index.md")

  def test_without_packages_twin_is_the_body
    assert_equal "# Plain\n\nBody.\n", twin("plain")
    assert_equal "Body.\n", twin("docpage") # only the reference layout shows the table
  end

  def test_table_before_body_with_title_and_text
    assert_equal <<~MD, twin("before")
      **Pkgs**

      | Name | Version | Links |
      | --- | --- | --- |
      | [`core`](https://example.org/core): Parse \\| render the model. | `1.0` | [Docs](/b/docs/), [Src](#) |
      | `cli` |  |  |

      Body.
    MD
  end

  def test_compact_table_after_body
    assert_equal <<~MD, twin("after")
      Body.

      | Name | Version | Links |
      | --- | --- | --- |
      | [`core`](https://example.org/core) | `1.0` | [Docs](/b/docs/), [Src](#) |
      | `cli` |  |  |
    MD
  end

  def test_llms_full_has_the_tables
    full = self.class.out.call("llms-full.txt")
    assert_includes full, twin("before")
    assert_includes full, twin("after")
    assert_includes full, "# Plain\n\nBody.\n"
  end
end
