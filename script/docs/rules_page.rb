# frozen_string_literal: true

require "pathname"
require_relative "../../lib/modootoday/markdown"

module DocsIndex
  # The docs Markdown rules page follows RULES.md, the one source: the reference/rules pages in every language carry
  # its text between the page-list markers. The text stays English; links to the docs site name the page's file.
  class RulesPage
    PAGE = "reference/rules"
    SITE = "https://modootoday.github.io/jekyll-theme-modootoday/"

    def initialize(tree, read)
      @t = tree
      @read = read
    end

    def files
      b, e = Modootoday::Markdown::INDEX_MARK % "begin", Modootoday::Markdown::INDEX_MARK % "end"
      @t.pages.select { |p| p.key == "#{PAGE}.md" }.each_with_object({}) do |p, h|
        src = @read.call(p.path)
        next unless src.include?(b) && src.include?(e)
        h[p.path] = src.sub(/#{Regexp.escape(b)}.*?#{Regexp.escape(e)}/m) { "#{b}\n#{text(p)}#{e}" }
      end
    end

    # RULES.md without its version line and title. The page is itself built by Jekyll, so a Liquid opener gets a
    # space; a bare badge prefix prints as its name, as on the Command line page.
    def text(page)
      src = File.read(File.expand_path("../../RULES.md", __dir__)).sub(/\A.*?^# [^\n]*\n+/m, "")
      src = src.gsub(/\]\(#{Regexp.escape(SITE)}([^)#]*)(#[^)]*)?\)/) { "](#{file(page, Regexp.last_match(1))}#{Regexp.last_match(2)})" }
      Modootoday::Markdown.plain_badge_prefixes(src.gsub("{%", "{ %").gsub("{{", "{ {"))
    end

    # A docs site URL as the file of the page's language that has it (the English one when it is not translated).
    def file(page, path)
      prefix = page.url.delete_suffix("/#{PAGE}/")
      target = @t.pages.find { |q| q.url == "#{prefix}/#{path}" } || @t.pages.find { |q| q.url == "/#{path}" }
      return "../../#{path}" unless target
      Pathname.new(target.rel).relative_path_from(Pathname.new(File.dirname(page.rel))).to_s
    end
  end
end
