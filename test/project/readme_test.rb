# frozen_string_literal: true
# README structure (recommended layout), README.ko.md parity, and drift of the generated Commands table.
require "minitest/autorun"
require "open3"

class ReadmeTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  EN = %w[Why Install Quick\ start Concepts Commands AI\ agents Guides Exit\ codes Contributing License].freeze
  KO = %w[왜 설치 빠른\ 시작 개념 명령 AI\ 에이전트 가이드 종료\ 코드 기여 라이선스].freeze

  def read(name) = File.read(File.join(ROOT, name))
  def h2(src) = src.gsub(/^```.*?^```/m, "").scan(/^## (.+)$/).flatten

  def test_both_readmes_exist_with_the_same_section_structure
    assert_equal EN, h2(read("README.md"))
    assert_equal KO, h2(read("README.ko.md"))
    assert_equal EN.size, KO.size
  end

  def test_shape_title_badges_links_and_length
    { "README.md" => "README.ko.md", "README.ko.md" => "README.md" }.each do |name, other|
      src = read(name)
      assert src.start_with?("# jekyll-theme-modootoday\n"), name
      assert_equal 3, src.scan(/^\[!\[[^\]]+\]\([^)]+\)\]\([^)]+\)$/).size, "#{name}: CI, gem version and license badges"
      assert_includes src, "llms.txt", name
      assert_includes src, "https://modootoday.github.io/jekyll-theme-modootoday/", name
      assert_includes src, "(#{other})", "#{name} links #{other}"
      assert_operator src.lines.size, :<=, 150, name
      assert_equal(h2(src).last, name == "README.md" ? "License" : "라이선스")
    end
  end

  def test_description_matches_gemspec_summary
    summary = read("jekyll-theme-modootoday.gemspec")[/spec\.summary\s*=\s*"([^"]+)"/, 1]
    assert_equal summary, read("README.md").lines[2].strip
  end

  def test_fenced_blocks_are_identical_in_both_languages
    fences = ->(s) { s.scan(/^```.*?^```/m) }
    assert_equal fences.(read("README.md")), fences.(read("README.ko.md"))
  end

  def test_commands_table_has_no_drift
    out, st = Open3.capture2e(RbConfig.ruby, File.join(ROOT, "script/readme-commands"), "--check")
    assert st.success?, out
  end

  def test_english_is_declared_canonical
    assert_match(/English is the canonical language/, read("README.md"))
    assert_match(/영어가 우선/, read("README.ko.md"))
    assert_match(/English is the canonical language/, read("CONTRIBUTING.md"))
  end
end
