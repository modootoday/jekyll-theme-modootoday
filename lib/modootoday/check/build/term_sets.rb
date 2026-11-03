# frozen_string_literal: true

require "json"
require_relative "structured_data"

module Modootoday
  module Check
    # Built site: a DefinedTerm page whose inDefinedTermSet points into this site (front matter term_set: as a site path)
    # names a built page whose graph holds that DefinedTermSet node, so the term and its glossary stay linked.
    module TermSets
      module_function

      def call(ctx)
        Dir.glob("#{ctx.site}/**/*.html").sort.each do |f|
          html = File.read(f)
          next unless html.include?('"inDefinedTermSet"')

          nodes = graph(html) or next
          root = nodes.find { |n| n["@type"] == "WebSite" }&.dig("url") or next
          nodes.each { |n| term(ctx, f, n, root) if Array(n["@type"]).include?("DefinedTerm") }
        end
      end

      def term(ctx, f, n, root)
        id = n["inDefinedTermSet"]
        id = id["@id"] if id.is_a?(Hash)
        return unless id.is_a?(String) && id.start_with?(root)

        path = id.delete_prefix(root).sub(/#.*\z/m, "")
        file = File.join(ctx.site, path.empty? || path.end_with?("/") ? "#{path}index.html" : path)
        set = File.file?(file) && graph(File.read(file))
        return ctx.errs << "#{f}: DefinedTerm term_set #{id} is not a page of this site" unless set
        return if set.any? { |t| t["@id"] == id && Array(t["@type"]).include?("DefinedTermSet") }

        ctx.errs << "#{f}: DefinedTerm term_set #{id} has no DefinedTermSet node (term_set: must be a glossary page URL)"
      end

      def graph(html)
        block = html[StructuredData::BLOCK, 1] or return nil
        Array(JSON.parse(block)["@graph"]).select { |n| n.is_a?(Hash) }
      rescue JSON::ParserError
        nil
      end
    end
  end
end
