# frozen_string_literal: true

module DocsRules
  # R8: links between docs pages are relative, and every guide and recipe links at least one other docs page.
  # An error page keeps root-absolute links: it is served at any URL, where a relative link would break.
  module Links
    BASE = %r{\]\(/jekyll-theme-modootoday/}

    module_function

    def call(pages)
      out = Hash.new { |h, k| h[k] = [] }
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
  end
end
