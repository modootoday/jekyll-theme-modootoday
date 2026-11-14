# frozen_string_literal: true

require "pathname"

module DocsRules
  # R8: links between docs pages are relative and name a file, and every guide and recipe links another docs page.
  # An error page keeps root-absolute links: it is served at any URL, where a relative link would break.
  module Links
    BASE = %r{\]\(/jekyll-theme-modootoday/}
    INLINE = /\]\((?<dest>[^)\s]+)(?<title>[ \t]+"[^"\n]*"|[ \t]+'[^'\n]*')?\)/
    REFDEF = /\A {0,3}\[(?!\^)[^\]\n]+\]:[ \t]*(?<dest>\S+)(?<title>[ \t]+["'].*)?$/
    EXTERNAL = %r{\A([a-z][a-z0-9+.-]*:|//|#)}i
    RESOLVE = "R8 relative links name a file"

    module_function

    def call(pages)
      out = Hash.new { |h, k| h[k] = [] }
      files(pages, out)
      pages.tree.langs.each do |lang|
        pages.docs(lang).each do |p|
          next if p.fm["layout"] == "error"
          pages.prose(p).each_line.with_index(1) do |l, i|
            out["R8 relative links"] << "#{p.rel}:#{i}: hard-coded base URL" if l.match?(BASE)
          end
        end
      end
      pages.docs.select { |p| p.key.start_with?("guides/", "recipes/") && !p.index? }.each do |p|
        others = pages.links(p).reject { |u| u == p.url || u.end_with?(".txt") }.select { |u| pages.by_url.key?(u) }
        out["R8 guides and recipes link a related page"] << "#{p.rel}: links no other docs page" if others.empty?
      end
      out
    end

    # A relative link names a file of docs/, so it opens on github.com, and jekyll-relative-links turns it into
    # that file's URL on both builders (adr:modootoday/20261114115001). The plugin skips a link titled on its line.
    def files(pages, out)
      root = pages.tree.root
      pages.markdown_files.each do |rel|
        text = File.read("#{root}/#{rel}")
        next if Modootoday::Markdown.fm(text)["layout"] == "error"
        body = Modootoday::Markdown.body(text)
        offset = text.count("\n") - body.count("\n")
        Modootoday::Markdown.strip_fences(body).each_line.with_index(1) do |l, i|
          prose = l.gsub(/(`+).*?\1/) { |m| " " * m.size }
          hits = prose.to_enum(:scan, INLINE).map { Regexp.last_match } + [prose.match(REFDEF)].compact
          hits.each do |m|
            problem = problem(root, rel, m[:dest], m[:title])
            out[RESOLVE] << "#{rel}:#{i + offset}: #{m[:dest]} #{problem}" if problem
          end
        end
      end
    end

    def problem(root, rel, dest, title)
      return nil if dest.match?(EXTERNAL)
      return "is root-absolute; name the file relative to this one" if dest.start_with?("/")
      path = dest.sub(/[#?].*\z/, "").gsub(/%\h\h/) { |h| h[1..].hex.chr }.force_encoding(Encoding::UTF_8)
      return nil if path.empty?
      file = Pathname.new(File.dirname(rel)).join(path).cleanpath.to_s
      return "leaves docs/" if file.start_with?("..")
      return "names no file in docs/ (a folder or a site URL does not open on GitHub)" unless File.file?(File.join(root, file))
      return "has its title on the same line, which jekyll-relative-links skips; use a reference definition with the title on the next line" if title
      nil
    end
  end
end
