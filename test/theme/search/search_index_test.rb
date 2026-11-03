# frozen_string_literal: true
# modootoday.search: what the search.json include indexes (words, fields, exclude, collections) and the header box
# attributes search.js reads (match, compact, results). Without the key the index and the box are as before.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "json"
require "jekyll"

class SearchIndexTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  LONG = (1..400).map { |i| "w#{i}" }.join(" ")

  def self.build(extra = "")
    (@b ||= {})[extra] ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(src)
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_config.yml"), "title: Site\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\n" \
                                                "sass: {silence_deprecations: [import, global-builtin]}\n" \
                                                "collections: {skills: {output: true}, notes: {output: false}}\n" \
                                                "defaults: [{scope: {path: ''}, values: {layout: doc}}]\n#{extra}")
      write(src, "index.md", "---\ntitle: Home\ndescription: Start here\ntags: [intro, guide]\n---\n# Home\n\n#{LONG}\n")
      write(src, "v1/old.md", "---\ntitle: Old\n---\n# Old\n\nLegacy text.\n")
      write(src, "_skills/rank.md", "---\ntitle: Rank tracker\n---\nTracks ranks.\n")
      write(src, "_notes/n.md", "---\ntitle: Note\n---\nHidden note.\n")
      write(src, "search.json", "---\nlayout: null\n---\n{% include modootoday/search.json %}\n")
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      File.join(dir, "_site")
    end
  end

  def self.write(src, rel, text)
    FileUtils.mkdir_p(File.dirname(File.join(src, rel)))
    File.write(File.join(src, rel), text)
  end

  def index(extra = "") = JSON.parse(File.read(File.join(self.class.build(extra), "search.json")))
  def entry(extra, title) = index(extra).find { |e| e["title"] == title }
  def box(extra = "") = File.read(File.join(self.class.build(extra), "index.html"))[/<div class="mt-search"[^>]*>/]

  def test_default_truncates_to_300_words_and_skips_collections
    home = entry("", "Home")
    assert_equal 300, home["text"].split.size
    assert entry("", "Old")
    refute entry("", "Rank tracker")
    assert_equal %w[url lang text], home.keys - ["title"]
  end

  # The body text starts with the page title (the # heading), then the 400 words.
  def test_words_zero_keeps_the_whole_text
    assert_equal 401, entry("modootoday: {search: {words: 0}}\n", "Home")["text"].split.size
    assert_equal 50, entry("modootoday: {search: {words: 50}}\n", "Home")["text"].split.size
  end

  def test_fields_go_before_the_text
    text = entry("modootoday: {search: {fields: [description, tags, missing], words: 2}}\n", "Home")["text"]
    assert_equal "Start here intro guide Home w1", text
  end

  def test_exclude_leaves_out_url_prefixes
    titles = index("modootoday: {search: {exclude: [/v1/]}}\n").map { _1["title"] }
    refute_includes titles, "Old"
    assert_includes titles, "Home"
  end

  def test_collections_with_output_are_indexed
    idx = index("modootoday: {search: {collections: [skills, notes]}}\n")
    rank = idx.find { _1["title"] == "Rank tracker" }
    assert_equal "/skills/rank/", rank["url"]
    assert_includes rank["text"], "Tracks ranks."
    refute(idx.any? { _1["title"] == "Note" }, "a collection without output has no page to link to")
  end

  def test_header_box_carries_the_match_options_only_when_set
    assert_equal '<div class="mt-search" role="search" data-index="/search.json" data-lang="en" hidden>', box
    assert_equal '<div class="mt-search" role="search" data-index="/search.json" data-lang="en" data-match="terms" data-compact data-results="12" hidden>',
                 box("modootoday: {search: {match: terms, compact: true, results: 12}}\n")
  end
end
