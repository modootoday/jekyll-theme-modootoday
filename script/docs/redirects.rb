# frozen_string_literal: true

require_relative "../../lib/modootoday/i18n"
require_relative "../../lib/modootoday/stubs/page"

module DocsIndex
  # Pages moved inside the docs: an English page's `moved_from: [recipes/charts.md]` keeps each old path as a
  # redirect stub (meta refresh, canonical, noindex) to the page, in English and in every language the page has.
  class Redirects
    MOVED = { "ko" => "%s 페이지로 옮겼습니다.", "ja" => "%s のページに移りました。" }.freeze

    def initialize(tree)
      @t = tree
    end

    def files
      moved.each_with_object({}) do |page, h|
        Array(page.fm["moved_from"]).each do |old|
          en = stub(page, nil)
          h["#{@t.root}/#{old}"] = en
          langs(page).each { |lang| h["#{@t.root}/#{old.sub(/\.md\z/, ".#{lang}.md")}"] = stub(@t.localized(page, lang), lang, old, en) }
        end
      end
    end

    private

    def moved = @t.pages.select { |p| p.lang == @t.default_lang && p.fm["moved_from"] }
    def langs(page) = (@t.langs - [@t.default_lang]).select { |l| @t.localized(page, l) }

    def stub(page, lang, old = nil, source = nil)
      head = lang ? "lang: #{lang}\npermalink: #{@t.page_lang.url(Modootoday::Stubs::Page.new(old, {}).url, lang)}\n" \
                    "source_rev: #{Modootoday::I18n::SourceRev.of(source)}\n" : ""
      moved = format(MOVED.fetch(lang, "Moved to the %s page."), page.title)
      "---\n#{head}title: #{q(page.title)}\ndescription: #{q(moved)}\nlayout: redirect\nredirect_to: #{page.url}\n" \
        "twin: false\nsitemap: false\nnav_exclude: true\n---\n"
    end

    def q(s) = s.to_s.match?(/[:#{}\[\],&*?|<>=!%@`'"]/) ? s.to_s.inspect : s.to_s
  end
end
