# frozen_string_literal: true
# Changelog feeds (layout: feed with feed_source:, docs-extra/feed-entries.html): both release shapes, one entry per
# release with a stable tag id, well-formed XML, and releases_feed: in the head and under a changelog page's title.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "rexml/document"
require "jekyll"

class ChangelogFeedTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  ATOM = "http://www.w3.org/2005/Atom"

  def self.site
    @site ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(File.join(src, "_data"))
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: Site\nlang: en\nurl: https://example.org\nbaseurl: /docs\nmarkdown: kramdown\npermalink: pretty\n" \
                                                "sass: {silence_deprecations: [import, global-builtin]}\ngithub: {repository_url: https://github.com/o/r}\n")
      File.write(File.join(src, "_data/releases.yml"), <<~YML)
        - {version: 2.0.0, date: '2026-11-02', url: https://github.com/o/r/releases/tag/v2.0.0, sections: [{name: Added, items: ["A & B"]}, {name: Fixed, items: [One]}]}
        - {version: 1.0.0, date: '2026-10-01', sections: [{name: Added, items: [First]}]}
      YML
      File.write(File.join(src, "changes.md"), "---\ntitle: Changes\nlayout: changelog\nfeed: /changes.xml\nreleases_feed: true\n" \
                                               "releases:\n  - {version: 1.1.0, date: 2026-10-20, added: [\"`code` bit\"], fixed: [Bug]}\n---\nBody.\n")
      File.write(File.join(src, "data.xml"), "---\nlayout: feed\nfeed_source: data\nhome: /changes/\n---\n")
      File.write(File.join(src, "changes.xml"), "---\nlayout: feed\nfeed_source: /changes/\n---\n")
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      File.join(dir, "_site")
    end
  end

  def feed(rel) = REXML::Document.new(File.read(File.join(self.class.site, rel)))

  def entries(doc) = REXML::XPath.match(doc, "//a:entry", "a" => ATOM)

  def text(node, path) = REXML::XPath.first(node, path, "a" => ATOM)&.text

  def test_generated_data_gives_one_entry_per_release_with_stable_ids
    doc = feed("data.xml")
    list = entries(doc)
    assert_equal %w[2.0.0 1.0.0], list.map { |e| text(e, "a:title") }
    assert_equal "tag:example.org,2026-11-02:/docs/2.0.0", text(list[0], "a:id")
    assert_equal "https://github.com/o/r/releases/tag/v2.0.0", REXML::XPath.first(list[0], "a:link", "a" => ATOM)["href"]
    assert_equal "https://example.org/docs/changes/#v1-0-0", REXML::XPath.first(list[1], "a:link", "a" => ATOM)["href"]
    assert_includes text(list[0], "a:content"), "<h3>Added</h3><ul><li>A &amp; B</li></ul>"
    assert_match(/\A2026-11-02T/, text(doc, "/a:feed/a:updated"))
  end

  def test_a_changelog_page_feeds_its_categories
    list = entries(feed("changes.xml"))
    assert_equal ["1.1.0"], list.map { |e| text(e, "a:title") }
    assert_match(%r{<li><code[^>]*>code</code> bit</li>}, text(list[0], "a:content"))
    assert_includes text(list[0], "a:content"), "<h3>Fixed</h3>"
  end

  def test_releases_feed_and_the_page_feed_are_linked
    h = File.read(File.join(self.class.site, "changes/index.html"))
    assert_includes h, '<link rel="alternate" type="application/atom+xml" title="GitHub releases" href="https://github.com/o/r/releases.atom">'
    assert_includes h, '<a href="https://github.com/o/r/releases.atom" type="application/atom+xml">'
    assert_includes h, "GitHub releases (Atom)"
    assert_includes h, '<a href="/docs/changes.xml" type="application/atom+xml">'
  end
end
