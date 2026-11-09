# frozen_string_literal: true

require_relative "../../lib/modootoday/markdown"

module DocsIndex
  # The docs Markdown rules page follows RULES.md, the one source: the reference/rules pages in every language carry
  # its text between the page-list markers. The text stays English; links to the docs site become relative.
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
        h[p.path] = src.sub(/#{Regexp.escape(b)}.*?#{Regexp.escape(e)}/m) { "#{b}\n#{text}#{e}" }
      end
    end

    # RULES.md without its version line and title. The page is itself built by Jekyll, so a Liquid opener gets a
    # space; a bare badge prefix prints as its name, as on the Command line page.
    def text
      @text ||= begin
        src = File.read(File.expand_path("../../RULES.md", __dir__)).sub(/\A.*?^# [^\n]*\n+/m, "")
        src = src.gsub("](#{SITE}", "](../../").gsub("{%", "{ %").gsub("{{", "{ {")
        Modootoday::Markdown.plain_badge_prefixes(src)
      end
    end
  end
end
