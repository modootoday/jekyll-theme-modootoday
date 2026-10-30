# frozen_string_literal: true

require "json"
require_relative "../schema/rules"

module Modootoday
  module Check
    # 6. Built site: schema.org JSON-LD. At most one application/ld+json block per page; valid JSON with the
    #    schema.org @context; every @type and property in the vocabulary; required properties per type
    #    (recommended ones are warnings with --schema-recommended); absolute URLs; ISO 8601 dates; unique @id; the page node agrees
    #    with og:url, og:title and og:image; inLanguage matches <html lang>.
    module StructuredData
      BLOCK = %r{<script type="application/ld\+json">(.*?)</script>}m
      CONTEXT = %r{\Ahttps?://schema\.org/?\z}
      # jekyll-seo-tag output (sites with seo: false that bring the plugin). Its JSON-LD is third-party markup the kit
      # does not write: it is checked only for valid JSON and noted as a warning, not held to the kit's rules
      # (for example WebPage with headline but no name). schema.org itself marks no property as required.
      SEO_TAG = /<!-- Begin Jekyll SEO tag.*?<!-- End Jekyll SEO tag -->/m

      module_function

      def call(ctx)
        Dir.glob("#{ctx.site}/**/*.html").sort.each { |f| page(ctx, f, File.read(f)) }
      end

      def page(ctx, f, html)
        html.scan(SEO_TAG).each do |seo|
          seo.scan(BLOCK).flatten.each do |b|
            JSON.parse(b)
            ctx.warns << "#{f}: JSON-LD from jekyll-seo-tag not checked against the kit's schema rules (third-party markup)"
          rescue JSON::ParserError => e
            ctx.errs << "#{f}: jekyll-seo-tag JSON-LD is not valid JSON (#{e.message[0, 80]})"
          end
        end
        html = html.gsub(SEO_TAG, "")
        blocks = html.scan(BLOCK).flatten
        return if blocks.empty?

        ctx.errs << "#{f}: #{blocks.size} JSON-LD blocks (use one @graph per page)" if blocks.size > 1
        blocks.each do |b|
          data = begin
            JSON.parse(b)
          rescue JSON::ParserError => e
            next ctx.errs << "#{f}: JSON-LD is not valid JSON (#{e.message[0, 80]})"
          end
          ctx.errs << "#{f}: JSON-LD @context is not https://schema.org" unless data["@context"].to_s =~ CONTEXT
          nodes = data.key?("@graph") ? Array(data["@graph"]) : [data]
          ids = nodes.filter_map { |n| n["@id"] if n.is_a?(Hash) }
          ids.tally.each { |id, c| ctx.errs << "#{f}: JSON-LD @id #{id} used by #{c} nodes" if c > 1 }
          nodes.each { |n| node(ctx, f, n, "@graph") }
          meta(ctx, f, html, nodes)
        end
      end

      # A node, then its nested nodes. Pure references ({"@id": ...}) need no @type.
      def node(ctx, f, n, path)
        return unless n.is_a?(Hash)

        types = Array(n["@type"])
        if types.empty?
          ctx.errs << "#{f}: JSON-LD #{path} has no @type" unless n.keys == ["@id"] || path.end_with?("]")
        end
        types.each { |t| ctx.errs << "#{f}: JSON-LD @type #{t} is not in the schema.org vocabulary" unless Schema.type?(t) }
        types.each { |t| required(ctx, f, n, t, path) }
        n.each do |k, v|
          next if %w[@context @type @graph].include?(k)

          ctx.errs << "#{f}: JSON-LD #{path}.#{k} is not a schema.org property" unless k.start_with?("@") || Schema.property?(k)
          values(ctx, f, k, v, "#{path}.#{k}")
        end
      end

      def values(ctx, f, k, v, path)
        Array(v).each_with_index do |x, i|
          next node(ctx, f, x, v.is_a?(Array) ? "#{path}[#{i}]" : path) if x.is_a?(Hash)
          next unless x.is_a?(String)

          ctx.errs << "#{f}: JSON-LD #{path} is not an absolute URL (#{x[0, 60]})" if Schema::URL_KEYS.include?(k) && x !~ %r{\Ahttps?://}
          ctx.errs << "#{f}: JSON-LD #{path} is not an ISO 8601 date (#{x[0, 40]})" if Schema::DATE_KEYS.include?(k) && x !~ Schema::ISO_8601
        end
      end

      def required(ctx, f, n, type, path)
        req, rec = Schema::RULES[type]
        return unless req

        has = ->(alt) { alt.split("|").any? { |p| !n[p].nil? && n[p] != "" && n[p] != [] } }
        req.each { |p| ctx.errs << "#{f}: JSON-LD #{type} (#{path}) lacks required #{p.tr('|', '/')}" unless has.(p) }
        return unless ctx.option?("--schema-recommended")

        rec.each { |p| ctx.warns << "#{f}: JSON-LD #{type} (#{path}) lacks recommended #{p.tr('|', '/')}" unless has.(p) }
      end

      # The page node (#webpage) against Open Graph and <html lang>: one source of truth for title, URL and image.
      def meta(ctx, f, html, nodes)
        pg = nodes.find { |n| n.is_a?(Hash) && n["@id"].to_s.end_with?("#webpage") } or return
        og = ->(p) { html[/<meta property="og:#{p}" content="([^"]*)"/, 1]&.then { |s| unescape(s) } }
        { "url" => pg["url"], "title" => pg["name"], "image" => pg.dig("primaryImageOfPage", "url") }.each do |p, v|
          o, v = og.(p)&.split&.join(" "), v&.split&.join(" ") if p == "title"
          o ||= og.(p)
          ctx.errs << "#{f}: JSON-LD #{p == 'title' ? 'name' : p} #{v.inspect} differs from og:#{p} #{o.inspect}" if o && v && o != v
        end
        lang = html[/<html[^>]*\blang="([^"]+)"/, 1]
        ctx.errs << "#{f}: JSON-LD inLanguage #{pg['inLanguage']} differs from <html lang=\"#{lang}\">" if lang && pg["inLanguage"] && lang != pg["inLanguage"]
      end

      def unescape(s) = s.gsub("&quot;", '"').gsub("&#39;", "'").gsub("&lt;", "<").gsub("&gt;", ">").gsub("&amp;", "&")
    end
  end
end
