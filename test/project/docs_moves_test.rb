# frozen_string_literal: true
# The docs demo to starter map (sot:modootoday/docs-demo-to-starter-map, "Verification"): its rows, the pages of done
# waves (a reference page with the live-demo include, or a redirect stub), the starter pages they point to, every layout
# in section 6, and the QA lists, which name no moved docs URL and only starter pages the starter's qa: list has.
require "minitest/autorun"
require "yaml"
require_relative "../../script/docs/tree"
require_relative "../../script/docs/outputs"

class DocsMovesTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  DOCS = "#{ROOT}/docs"
  LISTS = %w[test/system/audit/config.mjs test/system/audit/pages.mjs test/system/audit/layout/column-align.mjs
             test/system/audit/features/components.mjs test/system/visual/visual.mjs test/system/lighthouse/lighthouse.sh].freeze

  def moves = @moves ||= DocsIndex::Moves.new(DocsIndex::Tree.new(DOCS))
  def map = @map ||= File.read("#{ROOT}/#{DocsIndex::Moves::MAP}")
  def fm(path) = Modootoday::Markdown.fm(File.read(path)) || {}
  def langs(row) = row.en ? [nil] : [nil, "ko", "ja"]
  def file(row, lang) = "#{DOCS}/#{lang ? row.source.sub(/\.md\z/, ".#{lang}.md") : row.source}"
  def url(row) = Modootoday::Stubs::Page.new(row.source, {}).url.delete_prefix("/")

  # The source file of a page path in a starter: a page, a folder index, or a post under _posts.
  def page?(dir, page)
    p = page.delete_prefix("/")
    if (m = p.match(%r{(\d{4})/(\d{2})/(\d{2})/([\w-]+)/\z}))
      return File.file?("#{dir}/_posts/#{m[1]}-#{m[2]}-#{m[3]}-#{m[4]}.md")
    end
    return File.file?("#{dir}/#{p}") || File.file?("#{dir}/#{p.sub(/\.html\z/, ".md")}") unless p.empty? || p.end_with?("/")
    ["#{p}index.md", "#{p.chomp("/")}.md", "#{p}index.html"].any? { |f| File.file?("#{dir}/#{f.delete_prefix("/")}") }
  end

  def test_the_map_has_every_row_and_wave_one_is_done
    assert_equal 46, moves.rows.size
    assert_equal 32, moves.rows.count { |r| r.keep == "ref" }
    assert_equal [1], moves.done
    assert_equal 8, moves.moved.size
  end

  def test_rows_of_unpublished_waves_name_a_docs_page
    moves.rows.reject { |r| moves.done.include?(r.wave) || r.source.include?("<key>") }.each do |r|
      assert File.file?("#{DOCS}/#{r.source}"), "#{r.source}: no such docs page"
    end
  end

  def test_moved_rows_are_reference_pages_or_stubs_in_every_language
    moves.expanded.each do |r|
      assert_equal r.starter, moves.starter(r.starter).name
      langs(r).each do |lang|
        path = file(r, lang)
        assert File.file?(path), "#{path}: missing"
        if r.ref?
          assert_equal "layout-reference", fm(path)["layout"], "#{path}: a reference page shows the live demo"
        else
          assert_equal ["redirect", moves.url(r, lang)], fm(path).values_at("layout", "redirect_to"), path
        end
      end
    end
  end

  def test_record_rows_expand_to_the_count_the_map_names
    row = moves.moved.find { |r| r.source.include?("<key>") }
    count = map[/`#{Regexp.escape(row.source)}` \(en, (\d+)\)/, 1].to_i
    assert_equal count, moves.expanded.count { |r| r.source.start_with?(row.source.split("<key>").first) && !r.source.end_with?("index.md") }
  end

  def test_moved_rows_point_to_pages_the_starter_has
    moves.expanded.each do |r|
      s = moves.starter(r.starter)
      assert s.published, "#{r.source}: the #{s.name} starter is not published"
      assert page?(s.dir, r.page), "#{r.source}: the #{s.name} starter has no page #{r.page}"
    end
  end

  def test_every_layout_has_a_starter_in_section_six
    table = map[/^### 6\. .*?(?=^Features with)/m]
    listed = table.lines.grep(/\A\| [a-z]/).flat_map { |l| l.split("|")[1].split(",").map { |x| x.sub(/\(.*\)/, "").strip } }
    layouts = Dir.glob("#{ROOT}/_layouts/*.html").map { |f| File.basename(f, ".html") }
    assert_empty layouts - listed, "layouts with no starter in the map's section 6"
  end

  def test_qa_lists_name_no_moved_docs_url
    moved = moves.expanded.select(&:stub?).map { |r| url(r) }
    LISTS.each do |f|
      text = File.read("#{ROOT}/#{f}")
      moved.each { |u| refute_match(/["\s]#{Regexp.escape(u)}["\s]/, text, "#{f} names the moved #{u}") }
    end
  end

  def test_starter_lists_name_qa_pages_the_starter_has
    block = File.read("#{ROOT}/test/system/audit/config.mjs")[/^export const STARTERS = \{\n(.*?)^\};/m, 1]
    refute_nil block
    block.lines.each do |l|
      name = l[/\A  ([a-z-]+):/, 1] or next
      s = moves.starter(name)
      l.scan(/"([^"]*)"/).flatten.each { |p| assert_includes s.qa, p, "STARTERS.#{name} names #{p.inspect}, not in its qa: list" }
    end
  end

  # A docs page may link a moved demo in plain Markdown (its body stays its twin); the address must be a moved row's.
  def test_docs_link_only_the_starter_pages_of_moved_rows
    urls = moves.expanded.map { |r| moves.url(r) }
    Dir.glob("#{DOCS}/**/*.md").reject { |f| f.include?("/_") || f.include?("/generated/") }.each do |f|
      next if fm(f)["layout"] == "redirect"

      File.read(f).scan(%r{https://modootoday\.github\.io/jekyll-theme-modootoday-[a-z-]+-starter/[^\s)"]*}).each do |u|
        assert_includes urls, u, "#{f.delete_prefix("#{DOCS}/")}: #{u} is no starter page of a moved row"
      end
    end
  end

  def test_starter_qa_pages_exist
    %w[docs blog landing].map { |n| moves.starter(n) }.each do |s|
      s.qa.each { |p| assert page?(s.dir, p), "#{s.name}: qa: #{p.inspect} has no page" }
    end
  end
end
