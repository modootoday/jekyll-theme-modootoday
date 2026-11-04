# frozen_string_literal: true
# Site footer from _data/nav/footer[-<lang>].yml (modootoday/chrome/footer.html): columns, copyright, the per-language
# file, the footer sheet only with columns, and a site's own footer-custom.html replacing it.
require "minitest/autorun"
require_relative "../../support/layout_site"

class FooterTest < Minitest::Test
  include LayoutSite

  FOOTER = "columns:\n  - title: Docs\n    items:\n      - {title: Install, url: /guides/install/}\n" \
           "      - {title: Code, url: 'https://example.com/code'}\ncopyright: (c) Site\n"
  FOOTER_KO = "columns:\n  - title: 문서\n    items:\n      - {title: 설치, url: /ko/guides/install/}\n"
  PAGES = { "f/a.md" => ["title: A\n"], "f/b.md" => ["title: B\nlang: ko\n"] }.freeze

  def self.sites = @sites ||= {}

  def site(name, files)
    self.class.sites[name] ||= begin
      dir = Dir.mktmpdir
      at_exit { FileUtils.rm_rf(dir) }
      build_site(dir, PAGES, files: files)
    end
  end

  def footer(h) = h[%r{<footer class="mt-footer">.*?</footer>}m]

  def test_columns_copyright_and_sheet
    _, s = site("data", { "_data/nav/footer.yml" => FOOTER, "_data/nav/footer-ko.yml" => FOOTER_KO })
    f = footer(html(s, "f/a"))
    assert_match(%r{<div class="mt-footer-cols"><nav aria-label="Docs"><p class="mt-footer-title">Docs</p><ul><li><a href="/guides/install/">Install</a></li><li><a href="https://example.com/code">Code</a></li></ul></nav></div>}, f)
    assert_includes f, '<p class="mt-footer-copy">(c) Site</p>'
    assert_includes html(s, "f/a"), "modootoday/chrome/footer.css"
    ko = footer(html(s, "f/b"))
    assert_includes ko, ">설치</a>", "the per-language file wins"
    refute_includes ko, "(c) Site"
  end

  def test_no_data_no_footer_no_sheet
    _, s = site("plain", {})
    h = html(s, "f/a")
    refute_includes h, "mt-footer-cols"
    refute_includes h, "chrome/footer.css"
  end

  def test_site_override_wins
    own = "<footer class=\"mt-footer\"><p>Own</p></footer>\n"
    _, s = site("own", { "_data/nav/footer.yml" => FOOTER, "_includes/footer-custom.html" => own })
    assert_includes html(s, "f/a"), "<p>Own</p>"
    refute_includes html(s, "f/a"), "mt-footer-cols"
  end
end
