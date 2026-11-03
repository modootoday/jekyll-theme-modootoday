# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # How the theme and the site's own files reach the page: sheet mode, the ?v= query, site sheets, preload hints and the
      # site's module scripts. Front matter site_css: and preload: take the same shapes (build/site_assets.rb).
      module Delivery
        SITE_FILE = %r{\A/(?!/)\S+\z}
        SITE_CSS = %r{\A/(?!/)\S*\.css\z}
        PRELOAD_AS = %w[font image style script fetch].freeze
        SITE_JS = %r{\A/(?!/)\S*\.m?js\z}
        SCRIPT_NAME = /\A[a-z][a-z0-9-]*\z/
        SCRIPT_KEYS = %w[src css preload element].freeze
        # HTML custom element names: a lowercase letter first, a hyphen, and none of the names SVG and MathML reserve.
        ELEMENT = /\A[a-z][a-z0-9._]*-[a-z0-9._-]*\z/
        RESERVED = %w[annotation-xml color-profile font-face font-face-src font-face-uri font-face-format font-face-name missing-glyph].freeze

        module_function

        def site_css_errors(list) = list.reject { |p| p.is_a?(String) && p.match?(SITE_CSS) }.map { |p| "#{p.inspect} is not a site path to a .css file (/assets/css/site.css)" }

        def scripts_errors(map)
          map.flat_map do |name, e|
            w = "[#{name}]"
            next ["#{w}: the name must be lowercase letters, digits and hyphens (it is what script: names)"] unless name.to_s.match?(SCRIPT_NAME)
            next ["#{w} must be a map with src, such as {src: /assets/js/hero.js}"] unless e.is_a?(Hash)
            errs = []
            errs << "#{w}.src must be a site path to a .js file such as /assets/js/hero.js (got #{e['src'].inspect})" unless e["src"].to_s.match?(SITE_JS)
            errs << "#{w}.css must be a site path to a .css file (got #{e['css'].inspect})" if e.key?("css") && !e["css"].to_s.match?(SITE_CSS)
            errs << "#{w}.preload must be a list of site paths to .js files" if e.key?("preload") && !(e["preload"].is_a?(Array) && e["preload"].all? { |p| p.to_s.match?(SITE_JS) })
            errs << "#{w}.element must be a custom element name with a hyphen, such as x-counter (got #{e['element'].inspect})" if e.key?("element") && !(e["element"].to_s.match?(ELEMENT) && !RESERVED.include?(e["element"]))
            errs + (e.keys - SCRIPT_KEYS).map { |k| "#{w}: unknown key #{k} (#{SCRIPT_KEYS.join(', ')})" }
          end
        end

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
      Schema.register(Key.new(name: "scripts", type: :map, message: "must be a map of names to {src, css, preload, element}",
                              check: ->(ctx, path, v) { Delivery.scripts_errors(v).each { |e| ctx.errs << "_config.yml: #{path}#{e}" } }))
    end
  end
end
