# frozen_string_literal: true

require_relative "../../../../script/docs/tree"

module DocsRules
  # The docs pages the consistency rules (adr:modootoday/20261109200230) read: every page with its source text,
  # body without fenced code, and the internal links of its body resolved to URLs, so no rule needs a build.
  class Pages
    SAMPLE = %w[blog/ news/ authors/ _posts/ tags.md categories.md].freeze # the sample blog and its archives
    LINK = /\]\(([^)\s]+)(?:\s+"[^"]*")?\)/
    REFDEF = /^ {0,3}\[(?!\^)[^\]\n]+\]:[ \t]*(\S+)/

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

    # Internal links of a page's body (inline links and reference definitions), as site URLs without the fragment.
    def links(p)
      (@links ||= {})[p.path] ||= (prose(p).scan(LINK) + prose(p).scan(REFDEF)).flatten.filter_map { |u| resolve(p, u) }.uniq
    end

    def by_url = @by_url ||= all.to_h { |p| [p.url, p] }
    def by_rel = @by_rel ||= all.to_h { |p| [p.rel, p] }

    # Every Markdown file of the docs site a reader can open on GitHub: the pages and the sample posts.
    def markdown_files
      Dir.glob("#{tree.root}/**/*.md").map { |f| f.delete_prefix("#{tree.root}/") }
         .reject { |f| f.start_with?("#{DocsIndex::Tree::GENERATED}/", "vendor/") || (f.start_with?("_") && !f.start_with?("_posts/")) }.sort
    end

    private

    # A file link (upgrade.md) names its page; any other link is read as a URL relative to the page's URL.
    def resolve(page, href)
      return nil if href.match?(%r{\A([a-z][a-z0-9+.-]*:|//|#)}i)
      path = href.sub(/[#?].*\z/, "")
      return nil if path.empty?
      unless path.start_with?("/")
        target = by_rel[File.expand_path(path, File.dirname("/#{page.rel}")).delete_prefix("/")]
        return target.url if target
      end
      parts = (path.start_with?("/") ? [] : page.url.split("/").reject(&:empty?))
      path.split("/").each { |s| s == ".." ? parts.pop : (parts << s unless s.empty? || s == ".") }
      url = "/#{parts.join("/")}"
      url += "/" unless url.end_with?("/") || File.extname(url) != ""
      url.squeeze("/")
    end
  end
end
