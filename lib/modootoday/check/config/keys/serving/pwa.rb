# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # modootoday.pwa: the web app manifest and service worker settings (enabled: kill ships a self-removing worker). scope and
      # theme_color come from the baseurl and modootoday.theme_color. Paths carry no query, so no tracking parameters.
      module Pwa
        KEYS = %w[enabled name short_name description display start_url icons background_color precache].freeze
        ENABLED = [true, false, "kill"].freeze
        DISPLAY = %w[standalone minimal-ui browser].freeze
        PURPOSE = %w[any maskable monochrome].freeze
        ICON_KEYS = %w[src sizes purpose].freeze
        START = %r{\A/(?!/)[^\s?#]*\z}
        PNG = %r{\A/(?!/)\S*\.png\z}
        SIZES = /\A([1-9]\d*)x\1\z/
        HEX = /\A#(\h{3}|\h{6})\z/
        SHORT = 12

        module_function

        def check(ctx, path, v)
          errs = (v.keys - KEYS).map { |k| ": unknown key '#{k}' (known: #{KEYS.join(', ')})" }
          errs << ".enabled must be true, false or kill (got #{v['enabled'].inspect})" if v.key?("enabled") && !ENABLED.include?(v["enabled"])
          errs << ".display must be #{DISPLAY.join(', ')} (got #{v['display'].inspect})" if v.key?("display") && !DISPLAY.include?(v["display"])
          %w[name short_name description].each { |k| errs << ".#{k} must be text" if v.key?(k) && !(v[k].is_a?(String) && !v[k].strip.empty?) }
          errs << ".start_url must be a site path without a query or fragment, such as /guides/ (got #{v['start_url'].inspect})" if v.key?("start_url") && !v["start_url"].to_s.match?(START)
          errs << ".background_color must be a hex color such as #ffffff (got #{v['background_color'].inspect})" if v.key?("background_color") && !v["background_color"].to_s.match?(HEX)
          errs << ": no name (set modootoday.pwa.name or the site title)" if v["enabled"] == true && !v["name"] && ctx.site_cfg["title"].to_s.strip.empty?
          errs.concat(icon_errors(v["icons"])) if v.key?("icons")
          errs << ".precache must be a list of site paths without a query, such as [/guides/] (got #{v['precache'].inspect})" if v.key?("precache") && !(v["precache"].is_a?(Array) && v["precache"].all? { |p| p.to_s.match?(START) })
          errs.each { |e| ctx.errs << "_config.yml: #{path}#{e}" }
          warnings(ctx, path, v)
        end

        def icon_errors(icons)
          return [] if icons == "brand"
          return [".icons must be brand or a list of {src, sizes, purpose}"] unless icons.is_a?(Array) && !icons.empty?
          errs = icons.each_with_index.flat_map do |icon, i|
            w = ".icons[#{i}]"
            next ["#{w} must be a map with src and sizes"] unless icon.is_a?(Hash)
            e = (icon.keys - ICON_KEYS).map { |k| "#{w}: unknown key #{k} (#{ICON_KEYS.join(', ')})" }
            e << "#{w}.src must be a site path to a .png file such as /assets/icon-192.png (got #{icon['src'].inspect})" unless icon["src"].to_s.match?(PNG)
            e << "#{w}.sizes must be one square size such as 192x192 (got #{icon['sizes'].inspect})" unless icon["sizes"].to_s.match?(SIZES)
            e << "#{w}.purpose must be #{PURPOSE.join(', ')} (got #{icon['purpose'].inspect})" if icon.key?("purpose") && !PURPOSE.include?(icon["purpose"])
            e
          end
          return errs unless errs.empty?
          missing = %w[192 512].reject { |n| icons.any? { |icon| icon["sizes"] == "#{n}x#{n}" && icon.fetch("purpose", "any") == "any" } }
          missing.empty? ? [] : [".icons: add a #{missing.join(' and a ')} px icon with purpose any (browsers need both to install the site)"]
        end

        def warnings(ctx, path, v)
          short = v["short_name"] || v["name"] || ctx.site_cfg["title"]
          ctx.warns << "_config.yml: #{path}: the short name #{short.inspect} is over #{SHORT} characters; home screens cut it (set short_name)" if short.is_a?(String) && short.length > SHORT
          icons = v["icons"]
          ctx.warns << "_config.yml: #{path}.icons: add a maskable icon, or Android shows the icon shrunk inside a white circle" if icons.is_a?(Array) && icon_errors(icons).empty? && icons.none? { |i| i["purpose"] == "maskable" }
          return unless v["enabled"] == true && icons.nil? && ctx.mtc["favicon"] != "brand"
          ctx.warns << "_config.yml: #{path}: the app icon is the theme's mark; set icons: to your own (or icons: brand to keep it)"
        end
      end

      Schema.register(Key.new(name: "pwa", type: :map, message: "must be a map (enabled:, name:, short_name:, icons:, ...)",
                              check: ->(ctx, path, v) { Pwa.check(ctx, path, v) }))
    end
  end
end
