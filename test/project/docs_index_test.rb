# frozen_string_literal: true
# script/docs-index keeps every tool-written docs file under docs/generated/, each stub naming the path it stands for,
# and owns lang:, permalink: and (only with --stamp) source_rev: in each translation beside its source.
require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"
require "rbconfig"
require_relative "../../script/docs/tree"
require_relative "../../script/docs/outputs"

class DocsIndexTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  DOCS = "#{ROOT}/docs"
  GEN = "#{DOCS}/generated/"

  def outputs = @outputs ||= DocsIndex::Outputs.new(DocsIndex::Tree.new(DOCS))
  def stubs = outputs.files.select { |path, _| path.start_with?(GEN) }
  def fm(body) = Modootoday::Markdown.fm(body)

  def test_check_passes
    _, e, st = Open3.capture3(RbConfig.ruby, "#{ROOT}/script/docs-index", "--check")
    assert st.success?, e
  end

  def test_twin_stubs_name_the_page_beside_them
    twins = stubs.select { |path, _| path.end_with?(".md.txt") }
    refute_empty twins
    twins.each do |path, body|
      rel = path.delete_prefix(GEN)
      assert_equal rel, fm(body)["path"], path
      assert File.file?("#{DOCS}/#{rel.delete_suffix(".txt")}"), "#{path}: no page"
    end
  end

  def test_llms_files_for_each_language_with_a_home
    tree = DocsIndex::Tree.new(DOCS)
    tree.langs.each do |lang|
      dir = lang == tree.default_lang ? "" : "#{lang}/"
      %w[llms llms-full].each do |name|
        meta = fm(stubs.fetch("#{GEN}#{dir}#{name}.txt"))
        want = { "layout" => name, "path" => "#{name}.txt", "permalink" => "/#{dir}#{name}.txt" }
        want["lang"] = lang unless dir.empty?
        assert_equal want, meta
      end
    end
  end

  def test_translations_sit_beside_their_source_with_lang_permalink_and_source_rev
    tree = DocsIndex::Tree.new(DOCS)
    pl = tree.page_lang
    tracked = Dir.chdir(ROOT) { `git ls-files -z docs`.split("\0") }.map { |f| f.delete_prefix("docs/") }
    refute(tracked.any? { |f| pl.folder(f) }, "no translation in a <lang>/ folder")
    translations = tracked.select { |f| pl.sibling?(f) }
    refute_empty translations
    translations.each do |rel|
      meta = fm(File.read("#{DOCS}/#{rel}"))
      assert_equal pl.of(rel), meta["lang"], rel
      assert File.file?("#{DOCS}/#{pl.source(rel)}"), "#{rel}: no source"
      assert_match Modootoday::I18n::SourceRev::PATTERN, meta["source_rev"].to_s, rel
    end
  end

  def test_stamp_sets_source_rev_and_a_normal_run_keeps_it
    Dir.mktmpdir do |d|
      %w[_config.yml _data guides index.md].each { |f| FileUtils.cp_r("#{DOCS}/#{f}", d) }
      path = "#{d}/guides/install.ko.md"
      File.write(path, File.read(path).sub(/^source_rev: .*\n/, "").sub(/^permalink: .*\n/, ""))
      out = DocsIndex::Outputs.new(DocsIndex::Tree.new(d))
      body = out.files.fetch(path)
      assert_includes body, "lang: ko\npermalink: /ko/guides/install/\n"
      refute_includes body, "source_rev:", "a normal run never writes source_rev"
      rev = Modootoday::I18n::SourceRev.of(File.read("#{d}/guides/install.md"))
      assert_includes out.translations.stamp([path]).fetch(path), "permalink: /ko/guides/install/\nsource_rev: #{rev}\n"
      assert_raises(ArgumentError) { out.translations.stamp(["#{d}/guides/install.md"]) }
    end
  end

  # moved_from: keeps each old path of a moved page as a redirect to it, in every language the page has.
  def test_moved_pages_leave_a_redirect_at_each_old_path
    tree = DocsIndex::Tree.new(DOCS)
    moved = tree.pages.select { |p| p.lang == tree.default_lang && p.fm["moved_from"] }
    refute_empty moved
    moved.each do |page|
      Array(page.fm["moved_from"]).each do |old|
        tree.langs.filter_map { |l| tree.localized(page, l) }.each do |to|
          path = to.lang == tree.default_lang ? old : old.sub(/\.md\z/, ".#{to.lang}.md")
          meta = fm(File.read("#{DOCS}/#{path}"))
          assert_equal ["redirect", to.url, true], meta.values_at("layout", "redirect_to", "nav_exclude"), path
        end
      end
    end
  end

  def test_no_tool_output_outside_generated
    tracked = Dir.chdir(ROOT) { `git ls-files -z docs`.split("\0") }
    stray = tracked.reject { |f| f.start_with?("docs/generated/") }.select { |f| f.end_with?(".md.txt", "/llms.txt", "/llms-full.txt") }
    assert_empty stray
  end

  def test_changelog_page_lists_every_release_in_every_language
    versions = File.read("#{ROOT}/CHANGELOG.md").scan(/^## \[(\d+\.\d+\.\d+)\] - /).flatten
    data = YAML.safe_load(File.read("#{DOCS}/_data/releases.yml"))
    assert_equal versions, data.map { |r| r["version"] }
    data.each do |r|
      assert r["url"].to_s.end_with?("/v#{r["version"]}"), r["version"]
      r["sections"].each { |s| assert_equal s["count"], s["items"].count { |i| !i.strip.empty? }, "#{r["version"]} #{s["name"]}" }
    end
    Dir.glob("#{DOCS}/reference/changelog{,.*}.md").each do |page|
      heads = File.read(page).scan(/^### \[(\d+\.\d+\.\d+)\]/).flatten
      assert_equal versions, heads, page
    end
  end

  def test_rules_page_carries_every_rules_heading_in_every_language
    heads = File.read("#{ROOT}/RULES.md").scan(/^## .+$/)
    pages = Dir.glob("#{DOCS}/reference/rules{,.*}.md")
    assert_equal 3, pages.size
    pages.each do |page|
      list = File.read(page)[/<!-- spec:docs-index:begin -->(.*)<!-- spec:docs-index:end -->/m, 1].to_s
      assert_equal heads, list.scan(/^## .+$/), page
      refute_match(/\{[%{]/, list, "#{page}: Liquid opener in a page Jekyll renders")
    end
  end
end
