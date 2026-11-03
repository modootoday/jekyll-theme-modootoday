# frozen_string_literal: true
# Detail layouts: facts, one call to action, own bundle, JSON-LD main entity from front matter, checker contract.
require "minitest/autorun"
require_relative "../../support/layout_site"

class DetailLayoutsTest < Minitest::Test
  include LayoutSite

  PAGES = {
    "p.md" => "title: Atlas\nlayout: project\nclient: ACME\nyear: 2026\nstack: [Jekyll, Sass]\nlinks: [{label: Repo, url: 'https://example.com/r'}]\n",
    "cs.md" => "title: Faster docs\nlayout: case-study\ndescription: Lead.\ndate: 2026-09-01\nclient: ACME\n",
    "j.md" => "title: Writer\nlayout: job\ndescription: Write docs.\ndate: 2026-10-01\ndeadline: 2026-12-01\nemployment: full-time\nremote: South Korea\nlocation: Remote\nsalary: {min: 50000, max: 70000, currency: USD, unit: year}\napply: mailto:jobs@example.com\n",
    "e.md" => "title: Meetup\nlayout: event\nstarts: 2026-11-20 19:00:00 +0900\nends: 2026-11-20 21:00:00 +0900\nvenue: Hall A\nonline: 'https://example.com/live'\ntickets: 'https://example.com/t'\n",
    "ep.md" => "title: Pilot\nlayout: episode\ndate: 2026-10-10\nepisode: 3\nseason: 1\nduration: 42\naudio: /a.mp3\ntranscript: /t/\n",
  }.freeze

  def test_build_jsonld_and_markup
    Dir.mktmpdir do |d|
      src, s = build_site(d, PAGES)
      { "p.md" => "CreativeWork", "cs.md" => "Article", "j.md" => "JobPosting", "e.md" => "Event", "ep.md" => "PodcastEpisode" }.each do |n, t|
        assert_equal t, main_node(s, n)["@type"], n
        assert_includes html(s, n), "modootoday-detail.css"
        assert_includes html(s, n), 'aria-labelledby="mt-detail-title"'
      end
      j = main_node(s, "j.md")
      assert_equal %w[FULL_TIME TELECOMMUTE Country], [j["employmentType"], j["jobLocationType"], j["applicantLocationRequirements"]["@type"]]
      assert_equal "https://example.org/#publisher", j["hiringOrganization"]["@id"]
      assert_equal 50_000, j["baseSalary"]["value"]["minValue"]
      e = main_node(s, "e.md")
      assert_equal %w[Place VirtualLocation], e["location"].map { |l| l["@type"] }
      assert_equal "https://schema.org/MixedEventAttendanceMode", e["eventAttendanceMode"]
      ep = main_node(s, "ep.md")
      assert_equal [3, 1, "PT42M"], [ep["episodeNumber"], ep["partOfSeason"]["seasonNumber"], ep["associatedMedia"]["duration"]]
      assert_includes html(s, "e.md"), 'class="mt-ics"'
      assert_includes html(s, "ep.md"), "<audio controls"
      assert_match(/<dl class="mt-detail-facts">.*Jekyll/m, html(s, "p.md"))
      out, st = check(src, s)
      assert st.success?, out
    end
  end

  def test_checker_contracts
    Dir.mktmpdir do |d|
      bad = { "j.md" => "title: J\nlayout: job\nemployment: forever\n", "e.md" => "title: E\nlayout: event\n", "ep.md" => "title: Ep\nlayout: episode\n" }
      src, s = build_site(d, bad)
      out, st = check(src, s)
      refute st.success?
      ["employment must be one of", "set location:", "starts must be a date", "set venue:", "episode must be a number"].each { |m| assert_includes out, m }
    end
  end

  # The docs starter's records (_data/plugins.json, plugins/*.md): facts, Markdown body, directory cards and a stale record_index.
  def test_record_pages
    Dir.mktmpdir do |d|
      stale = "title: Ledger\nlayout: reference\npermalink: /refs/ledger/\nrecord: plugins/ledger\nrecord_index: 0\ntwin: false\n"
      src, s = build_site(d, { "refs/ledger.md" => [stale, ""] })
      h = html(s, "plugins/lantern.md")
      assert_match(%r{<dl class="mt-detail-facts mt-record-facts"><div><dt>Category</dt><dd>Reading</dd></div><div><dt>Version</dt><dd>2\.1\.0</dd></div>}, h)
      assert_includes h, '<dt>Tags</dt><dd><ul class="mt-detail-tags"><li>search</li><li>navigation</li></ul></dd>'
      assert_match(%r{<div class="mt-detail-body"><p>Lantern reads .*<h2 id="use">Use</h2>}m, h)
      assert_includes h, '<p class="mt-detail-lead">Highlights the section a reader came to from a search result.</p>'
      assert_match(%r{<div class="mt-dx-body"><p>Ledger turns}, html(s, "refs/ledger.md"), "where finds the record when the index is stale")
      list = html(s, "plugins.md")
      assert_includes list, '<a href="/plugins/lantern/">Lantern</a>'
      assert_includes list, '<p class="mt-dir-text">Sends new posts to a feed reader service.</p>'
      assert_includes list, '<p class="mt-dir-meta">Publishing</p>'
      assert_equal File.read("#{ROOT}/example/docs/_data/plugins.json"), File.read("#{ROOT}/docs/_data/plugins.json"), "the docs demo uses the docs starter's records"
      out, st = check(src, s, "--byte-exact=api")
      assert st.success?, out
    end
  end
end
