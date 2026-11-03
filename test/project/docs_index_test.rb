# frozen_string_literal: true
# script/docs-index keeps every tool-written docs file under docs/generated/, each stub naming the path it stands for.
require "minitest/autorun"
require "open3"
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
        want = { "layout" => name, "path" => "#{dir}#{name}.txt", "permalink" => "/#{dir}#{name}.txt" }
        want["lang"] = lang unless dir.empty?
        assert_equal want, meta
      end
    end
  end

  def test_no_tool_output_outside_generated
    tracked = Dir.chdir(ROOT) { `git ls-files -z docs`.split("\0") }
    stray = tracked.reject { |f| f.start_with?("docs/generated/") }.select { |f| f.end_with?(".md.txt", "/llms.txt", "/llms-full.txt") }
    assert_empty stray
  end
end
