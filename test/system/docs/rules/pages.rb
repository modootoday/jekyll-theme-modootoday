# frozen_string_literal: true

require_relative "../../../../script/docs/tree"

module DocsRules
  # The docs pages the consistency rules (adr:modootoday/20261109200230) read: every page with its source text,
  # body without fenced code, and the internal links of its body resolved to URLs, so no rule needs a build.
  class Pages
    SAMPLE = %w[blog/ news/ authors/ _posts/ tags.md categories.md].freeze # the sample blog and its archives
    LINK = /\]\(([^)\s]+)(?:\s+"[^"]*")?\)/

    attr_reader :tree

    def initialize(root)
      @tree = DocsIndex::Tree.new(root)
    end

    def all = @all ||= tree.pages.reject { |p| p.rel.start_with?("generated/") }
    def redirect?(p) = p.fm["layout"] == "redirect"
    def sample?(p) = SAMPLE.any? { |s| p.key.start_with?(s) } || p.fm["nav_section"] == "sample"

    # English docs pages that carry content: not redirects, not sample-site pages, not records.
    def docs(lang = tree.default_lang)
      all.select { |p| p.lang == lang && !redirect?(p) && !sample?(p) && !p.fm["record"] }
    end

    def source(p) = (@source ||= {})[p.path] ||= File.read(p.path)
    def body(p) = Modootoday::Markdown.strip_fences(Modootoday::Markdown.body(source(p)))

    # Body text with code spans removed: what a reader sees as prose.
    def prose(p) = body(p).gsub(/`[^`\n]*`/, "")

    # Internal links of a page's body, as site URLs without the fragment.
    def links(p)
      (@links ||= {})[p.path] ||= prose(p).scan(LINK).flatten.filter_map { |u| resolve(p.url, u) }.uniq
    end

    def by_url = @by_url ||= all.to_h { |p| [p.url, p] }

    private

    def resolve(from, href)
      return nil if href.match?(%r{\A([a-z][a-z0-9+.-]*:|//|#)}i)
      path = href.sub(/[#?].*\z/, "")
      return nil if path.empty?
      parts = (path.start_with?("/") ? [] : from.split("/").reject(&:empty?))
      path.split("/").each { |s| s == ".." ? parts.pop : (parts << s unless s.empty? || s == ".") }
      url = "/#{parts.join("/")}"
      url += "/" unless url.end_with?("/") || File.extname(url) != ""
      url.squeeze("/")
    end
  end
end
