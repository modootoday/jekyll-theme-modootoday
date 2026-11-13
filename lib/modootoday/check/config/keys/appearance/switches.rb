# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # A layout: feed page at /feed.xml writes the feed in Liquid, so feed: true then needs no plugin.
      feed_page = lambda do |ctx|
        Dir.glob(File.join(ctx.src, "**", "*.xml")).any? do |f|
          rel = ctx.rel(f)
          next false if rel.match?(Feeds::SKIP) || ctx.skipped?(f)
          fm = (Markdown.fm(File.read(f)) rescue nil)
          fm.is_a?(Hash) && fm["layout"] == "feed" && (fm["permalink"] || "/#{rel}") == "/feed.xml"
        end
      end
      feed_plugin = lambda do |ctx, path, v|
        next unless v == true && !Array(ctx.site_cfg["plugins"]).map(&:to_s).include?("jekyll-feed")
        next if feed_page.call(ctx)
        ctx.warns << "_config.yml: #{path}: true links /feed.xml; add a feed.xml page with layout: feed, or jekyll-feed to plugins"
      end
      %w[css_layers badges seo hreflang feed page_actions back_to_top loading].each do |name|
        Schema.register(Key.new(name: name, type: :bool, check: name == "feed" ? feed_plugin : nil))
      end
    end
  end
end
