# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # How the theme and the site's own files reach the page: sheet mode, the ?v= query, site sheets and preload hints.
      # Front matter site_css: and preload: take the same shapes (build/site_assets.rb).
      module Delivery
        SITE_FILE = %r{\A/(?!/)\S+\z}
        SITE_CSS = %r{\A/(?!/)\S*\.css\z}
        PRELOAD_AS = %w[font image style script fetch].freeze

        module_function

        def site_css_errors(list) = list.reject { |p| p.is_a?(String) && p.match?(SITE_CSS) }.map { |p| "#{p.inspect} is not a site path to a .css file (/assets/css/site.css)" }

        def preload_errors(list)
          list.each_with_index.flat_map do |item, i|
            next ["[#{i}] must be a map with href and as"] unless item.is_a?(Hash)
            errs = []
            errs << "[#{i}].href must be a site path such as /assets/fonts/x.woff2 (got #{item['href'].inspect})" unless item["href"].to_s.match?(SITE_FILE)
            errs << "[#{i}].as must be #{PRELOAD_AS.join(', ')} (got #{item['as'].inspect})" unless PRELOAD_AS.include?(item["as"])
            errs + (item.keys - %w[href as type]).map { |k| "[#{i}]: unknown key #{k} (href, as, type)" }
          end
        end
      end

      Schema.register(Key.new(name: "css", type: :enum, enum: %w[split bundle], message: "must be split or bundle"))
      Schema.register(Key.new(name: "asset_version", type: :enum, enum: ["theme", "build", false],
                              message: "must be theme, build or false (got %{got})"))
      Schema.register(Key.new(name: "site_css", type: :list,
                              check: ->(ctx, path, v) { Delivery.site_css_errors(v).each { |e| ctx.errs << "_config.yml: #{path}: #{e}" } }))
      Schema.register(Key.new(name: "preload", type: :list,
                              check: ->(ctx, path, v) { Delivery.preload_errors(v).each { |e| ctx.errs << "_config.yml: #{path}#{e}" } }))
    end
  end
end
