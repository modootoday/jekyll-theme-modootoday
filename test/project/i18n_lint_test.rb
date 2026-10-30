# frozen_string_literal: true
# script/i18n/lint.rb (translation style lint run by script/i18n-build --check), on temp-dir fixtures.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "../../script/i18n/lint"

class I18nLintTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  EN = "a: \"Read [n]\"\nb: \"Back\"\n"

  def setup
    @dir = Dir.mktmpdir
    FileUtils.mkdir_p(%W[#{@dir}/i18n #{@dir}/docs/ko #{@dir}/docs/ja])
    FileUtils.cp("#{ROOT}/i18n/glossary.yml", "#{@dir}/i18n/")
    w("i18n/languages.yml", "- {code: en}\n- {code: ko}\n- {code: ja}\n")
    w("i18n/en.yml", EN)
    w("i18n/ko.yml", "a: \"[n]분 읽기\"\nb: \"뒤로\"\n")
    w("i18n/ja.yml", "a: \"[n]分\"\nb: \"戻る\"\n")
  end

  def teardown = FileUtils.rm_rf(@dir)

  def w(rel, s) = File.write("#{@dir}/#{rel}", s)

  def run_lint = I18nLint.run(@dir)

  def test_clean_fixture_passes
    w("docs/ko/a.md", "# 제목\n\n테마는 Markdown 버전을 만듭니다.\n")
    w("docs/ja/a.md", "# 見出し\n\nテーマは Markdown 版を作ります。\n")
    assert_empty run_lint
  end

  def test_forbidden_term
    w("docs/ko/a.md", "테마는 쌍둥이를 만듭니다.\n")
    assert(run_lint.any? { |e| e.include?("'쌍둥이' → use 'Markdown 버전'") })
  end

  def test_japanese_long_vowel_term_but_not_the_correct_form
    w("docs/ja/a.md", "サーバで動きます。\n\nサーバーで動きます。\n")
    assert_equal 1, run_lint.count { |e| e.include?("'サーバ'") }
  end

  def test_haeyo_in_docs
    w("docs/ko/a.md", "테마를 설치해요.\n")
    assert(run_lint.any? { |e| e.include?("해요체") })
  end

  def test_plain_form_in_japanese
    w("docs/ja/a.md", "テーマを追加する。\n\n| 表 | 追加する。 |\n")
    assert_equal 1, run_lint.count { |e| e.include?("常体") }
  end

  def test_calque
    w("docs/ja/a.md", "項目を持つリストです。\n")
    assert(run_lint.any? { |e| e.include?("calque") })
  end

  def test_untranslated_english_outside_code
    w("docs/ko/a.md", "This sentence was never translated into Korean.\n\n```\nThis code line is fine and stays in English.\n```\n")
    errs = run_lint
    assert_equal 1, errs.count { |e| e.include?("untranslated") }
    assert(errs.any? { |e| e.include?("a.md:1:") })
  end

  def test_placeholder_mismatch_missing_key_and_spaces
    w("i18n/ko.yml", "a: \"읽기 \" \n")
    errs = run_lint
    assert(errs.any? { |e| e.include?("placeholders") })
    assert(errs.any? { |e| e.include?("missing key b") })
    assert(errs.any? { |e| e.include?("leading/trailing spaces") })
    assert(errs.any? { |e| e.include?("trailing whitespace") })
  end

  def test_sample_pages_keep_their_voice
    w("docs/ko/a.md", "---\nnoindex: true\n---\n오늘 새 기능을 소개해요.\n")
    assert_empty run_lint
  end

  def test_repository_is_clean
    assert_empty I18nLint.run(ROOT)
  end
end
