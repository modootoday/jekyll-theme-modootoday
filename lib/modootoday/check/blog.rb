# frozen_string_literal: true

module Modootoday
  module Check
    # Blog and news: modootoday.blog / modootoday.news settings, _data/authors.yml and post or listing front matter.
    module Blog
      VARIANTS = %w[list grid magazine].freeze
      LISTING = %w[blog news author].freeze
      POST = %w[post news-article].freeze

      module_function

      def call(ctx)
        settings(ctx)
        authors = load_authors(ctx)
        ctx.mds.each { |f| page(ctx, f, authors) }
      end

      def settings(ctx)
        mtc, errs = ctx.mtc, ctx.errs
        return unless mtc.is_a?(Hash)
        if mtc.key?("blog")
          b = mtc["blog"]
          k0 = "_config.yml: modootoday.blog"
          return errs << "#{k0} must be a map" unless b.is_a?(Hash)
          (b.keys - %w[variant per_page excerpt reading_time related share]).each { |k| errs << "#{k0}: unknown key '#{k}'" }
          errs << "#{k0}.variant must be one of #{VARIANTS.join(', ')}" if b.key?("variant") && !VARIANTS.include?(b["variant"].to_s)
          %w[per_page related].each { |k| errs << "#{k0}.#{k} must be a whole number" if b.key?(k) && !(b[k].is_a?(Integer) && b[k] >= 0) }
          %w[excerpt reading_time share].each { |k| errs << "#{k0}.#{k} must be true or false" if b.key?(k) && ![true, false].include?(b[k]) }
        end
        return unless mtc.key?("news")
        n = mtc["news"]
        ok = n.is_a?(Hash) && (n.keys - %w[sections]).empty? && (!n.key?("sections") || n["sections"].is_a?(Array))
        errs << "_config.yml: modootoday.news must be a map with sections: [category names]" unless ok
      end

      def load_authors(ctx)
        f = "#{ctx.src}/_data/authors.yml"
        return nil unless File.exist?(f)
        data = (YAML.safe_load(File.read(f)) rescue (ctx.errs << "_data/authors.yml: YAML error"; nil))
        return nil unless data
        return (ctx.errs << "_data/authors.yml must map author ids to {name:, url:, page:, bio:}"; nil) unless data.is_a?(Hash)
        data.each do |id, a|
          next ctx.errs << "_data/authors.yml: #{id} must be a map with name:" unless a.is_a?(Hash) && a["name"].to_s != ""
          ctx.errs << "_data/authors.yml: #{id}.url must be an http(s) URL" if a["url"] && a["url"].to_s !~ %r{\Ahttps?://\S+\z}
          ctx.errs << "_data/authors.yml: #{id}.page must be a site path starting with /" if a["page"] && !a["page"].to_s.start_with?("/")
        end
        data
      end

      def page(ctx, f, authors)
        fm = (Markdown.fm(File.read(f)) rescue nil)
        return unless fm.is_a?(Hash)
        r = ctx.rel(f)
        layout = fm["layout"].to_s
        post = r.split("/").include?("_posts") || POST.include?(layout)
        if LISTING.include?(layout)
          ctx.errs << "#{r}: variant must be one of #{VARIANTS.join(', ')}" if fm.key?("variant") && !VARIANTS.include?(fm["variant"].to_s)
          ctx.errs << "#{r}: news_sections must be a list of category names" if fm.key?("news_sections") && !fm["news_sections"].is_a?(Array)
        end
        ctx.errs << "#{r}: layout: author needs author: <id from _data/authors.yml>" if layout == "author" && fm["author"].to_s.empty?
        ids = Array(fm["authors"] || fm["author"]).map(&:to_s)
        if authors && (post || layout == "author")
          ids.each { |id| ctx.warns << "#{r}: author '#{id}' is not in _data/authors.yml (shown as plain text)" unless authors.key?(id) }
        end
        return unless post
        %w[breaking live featured].each { |k| ctx.errs << "#{r}: #{k} must be true or false" if fm.key?(k) && ![true, false].include?(fm[k]) }
        ctx.errs << "#{r}: sources must be a list" if fm.key?("sources") && !fm["sources"].is_a?(Array)
      end
    end
  end
end
