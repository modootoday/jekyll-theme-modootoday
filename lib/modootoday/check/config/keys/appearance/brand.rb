# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "logo", type: :text, message: "must be brand or the path of an image"))
      Schema.register(Key.new(name: "favicon", type: :text, message: "must be brand or the path of an icon"))
      # A path, or {path, alt, width, height}: the map adds og:image:alt and the size crawlers use before they fetch.
      og_image = lambda do |ctx, path, v|
        next if v.is_a?(String) && !v.strip.empty?
        unless v.is_a?(Hash) && v["path"].is_a?(String) && (v.keys - %w[path alt width height]).empty?
          next ctx.errs << "_config.yml: #{path} must be the path or URL of an image, or a map {path, alt, width, height}"
        end
        %w[width height].each { |k| ctx.errs << "_config.yml: #{path}.#{k} must be a whole number of pixels" if v.key?(k) && !(v[k].is_a?(Integer) && v[k].positive?) }
        ctx.warns << "_config.yml: #{path} has no alt: a shared link shows the image without a text alternative" if v["alt"].to_s.strip.empty?
      end
      Schema.register(Key.new(name: "og_image", type: :any, check: og_image))

      hex = /\A#(\h{3}|\h{4}|\h{6}|\h{8})\z/
      scheme_colors = lambda do |ctx, path, v|
        ok = v == false || v.to_s.match?(hex) ||
             (v.is_a?(Hash) && !v.empty? && (v.keys - %w[light dark]).empty? && v.values.all? { |c| c.to_s.match?(hex) })
        ctx.errs << "_config.yml: #{path} must be a \"#hex\" color, {light: \"#hex\", dark: \"#hex\"} or false (got #{v.inspect})" unless ok
      end
      Schema.register(Key.new(name: "theme_color", type: :any, check: scheme_colors))
    end
  end
end
