# frozen_string_literal: true
# Docs-extra layouts (own bundle), legal (pages bundle) and resume (own print-first bundle): markup, structured data, checker.
require "minitest/autorun"
require_relative "site"

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
    "l.md" => "title: Terms\nlayout: legal\neffective: 2026-01-01\nupdated: 2026-10-01\ntoc: [{title: Use}]\n",
    "cv.md" => "title: CV\nlayout: resume\nname: Ada\nheadline: Engineer\nemail: ada@example.com\nlinks: [{label: GitHub, url: 'https://github.com/ada'}]\n" \
               "experience: [{role: Lead, org: Acme, start: 2024-01-01}, {role: Dev, org: Old, start: 2020-01-01, end: 2023-12-01}]\n" \
               "education: [{degree: BSc, school: Uni}]\nskills: [{group: Lang, items: [Ruby, Go]}]\n",
  }.freeze

  def test_build
    Dir.mktmpdir do |d|
      src, s = build_site(d, PAGES)
      %w[r c m g h co b].each { |n| assert_includes html(s, "#{n}.md"), "modootoday-docs-extra.css", n }
      assert_includes html(s, "l.md"), "modootoday-pages.css"
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
end
