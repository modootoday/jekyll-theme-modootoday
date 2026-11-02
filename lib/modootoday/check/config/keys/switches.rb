# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      feed_plugin = lambda do |ctx, path, v|
        next unless v == true && !Array(ctx.site_cfg["plugins"]).map(&:to_s).include?("jekyll-feed")
        ctx.warns << "_config.yml: #{path}: true links /feed.xml; add jekyll-feed to plugins"
      end
      %w[css_layers badges seo hreflang feed page_actions back_to_top loading].each do |name|
        Schema.register(Key.new(name: name, type: :bool, check: name == "feed" ? feed_plugin : nil))
      end
    end
  end
end
