# frozen_string_literal: true
# README structure (recommended layout), README.ko.md and README.ja.md parity, and drift of the generated Commands table.
require "minitest/autorun"
require "open3"

class ReadmeTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  EN = %w[Why Install Quick\ start Concepts Commands AI\ agents Guides Exit\ codes Contributing License].freeze
  KO = %w[왜 설치 빠른\ 시작 개념 명령 AI\ 에이전트 가이드 종료\ 코드 기여 라이선스].freeze
  JA = %w[特長 インストール クイックスタート 考え方 コマンド AI\ エージェント ガイド 終了コード コントリビュート ライセンス].freeze
  READMES = { "README.md" => EN, "README.ko.md" => KO, "README.ja.md" => JA }.freeze

  def read(name) = File.read(File.join(ROOT, name))
  def h2(src) = src.gsub(/^```.*?^```/m, "").scan(/^## (.+)$/).flatten

  def test_every_readme_exists_with_the_same_section_structure
    READMES.each { |name, heads| assert_equal heads, h2(read(name)), name }
    assert_equal [EN.size], READMES.values.map(&:size).uniq
  end

  def test_shape_title_badges_links_and_length
    READMES.each do |name, heads|
      src = read(name)
      assert src.start_with?("# jekyll-theme-modootoday\n"), name
      assert_equal 3, src.scan(/^\[!\[[^\]]+\]\([^)]+\)\]\([^)]+\)$/).size, "#{name}: CI, gem version and license badges"
      assert_includes src, "llms.txt", name
      assert_includes src, "https://modootoday.github.io/jekyll-theme-modootoday/", name
      (READMES.keys - [name]).each { |other| assert_includes src, "(#{other})", "#{name} links #{other}" }
      assert_operator src.lines.size, :<=, 150, name
      assert_equal heads.last, h2(src).last, name
    end
  end

  def test_description_matches_gemspec_summary
    summary = read("jekyll-theme-modootoday.gemspec")[/spec\.summary\s*=\s*"([^"]+)"/, 1]
    assert_equal summary, read("README.md").lines[2].strip
  end

  def test_fenced_blocks_are_identical_in_every_language
    fences = ->(s) { s.scan(/^```.*?^```/m) }
    %w[README.ko.md README.ja.md].each { |name| assert_equal fences.(read("README.md")), fences.(read(name)), name }
  end

  def test_commands_table_has_no_drift
    out, st = Open3.capture2e(RbConfig.ruby, File.join(ROOT, "script/readme-commands"), "--check")
    assert st.success?, out
  end

  def test_english_is_declared_canonical
    assert_match(/English is the canonical language/, read("README.md"))
    assert_match(/영어가 우선/, read("README.ko.md"))
    assert_match(/英語版が優先/, read("README.ja.md"))
    assert_match(/English is the canonical language/, read("CONTRIBUTING.md"))
  end
end
