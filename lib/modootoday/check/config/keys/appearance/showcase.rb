# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # modootoday.showcase: the bar or pill of a starter demo build (chrome/showcase.html). It belongs in a demo-only file
      # layered over _config.yml (_config.demo.yml, read here too), so a site made from the starter does not inherit it.
      module Showcase
        KEYS = %w[enabled style starter docs_url use_url].freeze
        HTTPS = %r{\Ahttps://\S+\z}
        DEMO = "_config.demo.yml"

        module_function

        def check(ctx, file, path, v)
          (v.keys - KEYS).each { |k| ctx.errs << "#{file}: #{path}: unknown key '#{k}' (known: #{KEYS.join(', ')})" }
          ctx.errs << "#{file}: #{path}.enabled must be true or false" if v.key?("enabled") && !Validate::BOOL.include?(v["enabled"])
          ctx.errs << "#{file}: #{path}.style must be bar or pill" if v.key?("style") && !%w[bar pill].include?(v["style"])
          %w[docs_url use_url].each { |k| ctx.errs << "#{file}: #{path}.#{k} must be an https:// URL" if v.key?(k) && !v[k].to_s.match?(HTTPS) }
          ctx.errs << "#{file}: #{path}.docs_url is required when enabled is true" if v["enabled"] == true && !v.key?("docs_url")
          starter(ctx, file, path, v["starter"]) if v.key?("starter")
        end

        # The label names the starter only when a catalog has showcase.starters.<name>: the theme's or the site's.
        def starter(ctx, file, path, name)
          return ctx.errs << "#{file}: #{path}.starter must be a name (letters, digits, - and _)" unless name.is_a?(String) && name.match?(Validate::NAME)
          theme = YAML.safe_load(File.read("#{I18n::THEME}/en.yml")).dig("showcase", "starters") || {}
          return if theme.key?(name) || ctx.i18n.values.any? { |h| h.is_a?(Hash) && h.dig("showcase", "starters", name) }
          ctx.warns << "#{file}: #{path}.starter '#{name}' has no showcase.starters.#{name} label (theme or _data/i18n); the showcase names only the theme"
        end

        def demo_config(ctx)
          f = File.join(ctx.src, DEMO)
          File.file?(f) ? ((YAML.safe_load(File.read(f)) rescue nil) || {}) : {}
        end

        def enabled?(ctx)
          [ctx.mtc, demo_config(ctx)["modootoday"]].any? { |m| m.is_a?(Hash) && m["showcase"].is_a?(Hash) && m["showcase"]["enabled"] == true }
        end

        def demo(ctx)
          v = demo_config(ctx).dig("modootoday", "showcase") if demo_config(ctx)["modootoday"].is_a?(Hash)
          return if v.nil?
          return ctx.errs << "#{DEMO}: modootoday.showcase must be a map (enabled:, style:, starter:, docs_url:, use_url:)" unless v.is_a?(Hash)
          check(ctx, DEMO, "modootoday.showcase", v)
        end
      end

      in_config = lambda do |ctx, path, v|
        Showcase.check(ctx, "_config.yml", path, v)
        next unless v["enabled"] == true
        ctx.warns << "_config.yml: #{path}.enabled: sites made from this one show it too; set it in #{Showcase::DEMO}, layered by the demo build"
      end
      Schema.register(Key.new(name: "showcase", type: :map, message: "must be a map (enabled:, style:, starter:, docs_url:, use_url:)", check: in_config))
    end
  end
end
