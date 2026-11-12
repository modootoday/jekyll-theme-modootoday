# frozen_string_literal: true

require "rexml/document"

module Modootoday
  module Check
    # Front matter feed: on a page names its Atom feed (meta/feed-url.html): false, or a site path to an .xml page that
    # exists in the build. The theme drops a feed it cannot find, so a wrong path would lose the link without a word.
    # A feed page's feed_source: is "data" or a built page; every built Atom feed must be well-formed XML.
    module Feeds
      SKIP = %r{(?:\A|/)(?:_site|node_modules|vendor|\.[^/]+)/}

      module_function

      def call(ctx)
        ctx.mds.each do |f|
          fm = (Markdown.fm(File.read(f)) rescue nil)
          next unless fm.is_a?(Hash) && fm.key?("feed")
          problem = check(ctx.site, fm["feed"])
          ctx.errs << "#{ctx.rel(f)}: feed: #{problem}" if problem
        end
        sources(ctx)
        built(ctx)
      end

      def check(site, feed)
        return if feed == false
        return "must be false or a site path to the page's Atom feed, such as /blog/feed.xml (got #{feed.inspect})" unless feed.is_a?(String) && feed.start_with?("/") && feed.end_with?(".xml")
        return if File.file?(File.join(site, feed))
        "#{feed} is not in the build: add a page with layout: feed at that permalink, or fix the path"
      end

      # feed_source: on .xml pages with front matter (layout: feed).
      def sources(ctx)
        Dir.glob(File.join(ctx.src, "**", "*.xml")).sort.each do |f|
          next if ctx.rel(f).match?(SKIP)
          fm = (Markdown.fm(File.read(f)) rescue nil)
          next unless fm.is_a?(Hash) && fm.key?("feed_source")
          source = fm["feed_source"]
          next if source == "data"
          unless source.is_a?(String) && source.start_with?("/")
            ctx.errs << "#{ctx.rel(f)}: feed_source: must be data or the URL of a layout: changelog page, such as /changelog/ (got #{source.inspect})"
            next
          end
          page = File.join(ctx.site, source, source.end_with?("/") ? "index.html" : "")
          ctx.errs << "#{ctx.rel(f)}: feed_source: #{source} is not in the build" unless File.file?(page) || File.file?("#{page}.html")
        end
      end

      def built(ctx)
        Dir.glob(File.join(ctx.site, "**", "*.xml")).sort.each do |f|
          text = File.read(f)
          next unless text.include?("<feed")
          begin
            REXML::Document.new(text)
          rescue REXML::ParseException => e
            ctx.errs << "#{ctx.rel(f)}: the Atom feed is not well-formed XML: #{e.message.lines.first.to_s.strip}"
          end
        end
      end
    end
  end
end
