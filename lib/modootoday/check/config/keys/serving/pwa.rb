# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # modootoday.pwa: the web app manifest and service worker settings (enabled: kill ships a self-removing worker). scope and
      # theme_color come from the baseurl and modootoday.theme_color. Paths carry no query, so no tracking parameters.
      # shortcuts and screenshots are opt-in lists for the app icon menu and the install dialog.
      module Pwa
        KEYS = %w[enabled name short_name description display start_url icons background_color precache shortcuts screenshots].freeze
        ENABLED = [true, false, "kill"].freeze
        DISPLAY = %w[standalone minimal-ui browser].freeze
        PURPOSE = %w[any maskable monochrome].freeze
        ICON_KEYS = %w[src sizes purpose].freeze
        SHORTCUT_KEYS = %w[name short_name description url].freeze
        SHOT_KEYS = %w[src sizes form_factor label].freeze
        FORM = %w[wide narrow].freeze
        RECT = /\A([1-9]\d*)x([1-9]\d*)\z/
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
          errs.concat(shortcut_errors(v["shortcuts"])) if v.key?("shortcuts")
          errs.concat(screenshot_errors(v["screenshots"])) if v.key?("screenshots")
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

        def text?(v) = v.is_a?(String) && !v.strip.empty?

        def list_errors(key, list, keys, required)
          return [".#{key} must be a list of {#{keys.join(', ')}}"] unless list.is_a?(Array) && !list.empty?
          list.each_with_index.flat_map do |item, i|
            w = ".#{key}[#{i}]"
            next ["#{w} must be a map with #{required.join(' and ')}"] unless item.is_a?(Hash)
            (item.keys - keys).map { |k| "#{w}: unknown key #{k} (#{keys.join(', ')})" } + yield(w, item)
          end
        end

        def shortcut_errors(list)
          list_errors("shortcuts", list, SHORTCUT_KEYS, %w[name url]) do |w, s|
            e = %w[name short_name description].select { |k| (k == "name" || s.key?(k)) && !text?(s[k]) }.map { |k| "#{w}.#{k} must be text" }
            e << "#{w}.url must be a site path without a query or fragment, such as /guides/ (got #{s['url'].inspect})" unless s["url"].to_s.match?(START)
            e
          end
        end

        def screenshot_errors(list)
          list_errors("screenshots", list, SHOT_KEYS, %w[src sizes]) do |w, s|
            e = []
            e << "#{w}.src must be a site path to a .png file such as /assets/screens/home.png (got #{s['src'].inspect})" unless s["src"].to_s.match?(PNG)
            e << "#{w}.sizes must be one size such as 1280x720 (got #{s['sizes'].inspect})" unless s["sizes"].to_s.match?(RECT)
            e << "#{w}.form_factor must be #{FORM.join(' or ')} (got #{s['form_factor'].inspect})" if s.key?("form_factor") && !FORM.include?(s["form_factor"])
            e << "#{w}.label must be text" if s.key?("label") && !text?(s["label"])
            e
          end
        end

        # Chromium skips a screenshot with a side outside 320-3840 px or one side over 2.3 times the other, and shows the
        # richer dialog on desktop only with a wide one.
        def screenshot_warnings(ctx, path, list)
          return unless list.is_a?(Array) && screenshot_errors(list).empty?
          list.each_with_index do |s, i|
            w, h = s["sizes"].split("x").map(&:to_i)
            next if [w, h].all? { |n| n.between?(320, 3840) } && [w, h].max <= 2.3 * [w, h].min
            ctx.warns << "_config.yml: #{path}.screenshots[#{i}]: browsers skip #{s['sizes']} (each side 320-3840 px, at most 2.3:1)"
          end
          return if list.any? { |s| s["form_factor"] == "wide" }
          ctx.warns << "_config.yml: #{path}.screenshots: none has form_factor: wide, so desktop browsers show the plain install dialog"
        end

        def warnings(ctx, path, v)
          short = v["short_name"] || v["name"] || ctx.site_cfg["title"]
          ctx.warns << "_config.yml: #{path}: the short name #{short.inspect} is over #{SHORT} characters; home screens cut it (set short_name)" if short.is_a?(String) && short.length > SHORT
          screenshot_warnings(ctx, path, v["screenshots"])
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
