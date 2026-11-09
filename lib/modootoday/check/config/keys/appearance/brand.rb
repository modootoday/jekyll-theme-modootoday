# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "logo", type: :text, message: "must be brand or the path of an image"))
      Schema.register(Key.new(name: "favicon", type: :text, message: "must be brand or the path of an icon"))
      Schema.register(Key.new(name: "og_image", type: :text, message: "must be the path or URL of an image"))

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
