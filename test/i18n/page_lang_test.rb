# frozen_string_literal: true
# Modootoday::I18n::PageLang: the language, source and URL of a page in sibling and directory mode.
require "minitest/autorun"
require_relative "../../lib/modootoday/i18n"

class PageLangTest < Minitest::Test
  def pl = Modootoday::I18n::PageLang.new(%w[en ko ja pt-BR], "en")

  def test_sibling_mode
    assert_equal "ko", pl.of("guides/install.ko.md")
    assert_equal "pt-BR", pl.of("home/index.pt-BR.md")
    assert_equal "guides/install.md", pl.source("guides/install.ko.md")
    assert_equal "index.md", pl.source("home/index.pt-BR.md")
    assert_equal "feed.xml", pl.source("feed.ja.xml")
    assert_equal "guides/install.ja.md", pl.sibling("guides/install.md", "ja")
    assert pl.sibling?("index.ko.md")
  end

  def test_directory_mode
    assert_equal "ko", pl.of("ko/guides/install.md")
    assert_equal "guides/install.md", pl.source("ko/guides/install.md")
    assert pl.translation?("ko/guides/install.md")
    refute pl.sibling?("ko/guides/install.md")
  end

  def test_default_language_and_front_matter
    assert_equal "en", pl.of("guides/install.md")
    assert_equal "en", pl.of("v1.2.md")
    assert_equal "en", pl.of("guides/install.en.md"), "the default language has no suffix"
    assert_equal "ja", pl.of("guides/install.ko.md", { "lang" => "ja" })
    assert_equal "guides/install.md", pl.source("guides/install.md")
    refute pl.translation?("ko.md")
  end

  def test_url
    assert_equal "/ko/guides/install/", pl.url("/guides/install/", "ko")
    assert_equal "/ja/", pl.url("/", "ja")
    assert_equal "/guides/install/", pl.url("/guides/install/", "en")
  end
end
