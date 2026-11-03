# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      css_values = lambda do |ctx, path, map|
        map.each do |name, val|
          ctx.warns << "_config.yml: #{path}.#{name}: not a semantic token (#{SiteConfig::SEMANTIC.join(', ')})" unless SiteConfig::SEMANTIC.include?(name.to_s)
          v = val.to_s.strip
          if v.empty? || v =~ /[;{}<>]/ || v !~ /\A[#\w\s.,%()"'+\-*\/]+\z/
            ctx.errs << "_config.yml: #{path}.#{name}: invalid CSS value #{val.inspect}"
          elsif v.start_with?("#") && v !~ /\A#(\h{3}|\h{4}|\h{6}|\h{8})\z/
            ctx.errs << "_config.yml: #{path}.#{name}: invalid hex color #{val.inspect}"
          end
        end
      end
      %w[tokens tokens_dark].each { |name| Schema.register(Key.new(name: name, type: :map, check: css_values)) }

      # A code preset colours Rouge's classes only; another highlighter leaves the blocks plain.
      rouge = lambda do |ctx, path, v|
        next if v == "theme"
        cfg = ctx.site_cfg
        kd = cfg["kramdown"].is_a?(Hash) && cfg["kramdown"].key?("syntax_highlighter") ? cfg["kramdown"]["syntax_highlighter"].to_s : "rouge"
        off = (cfg.key?("highlighter") && cfg["highlighter"].to_s != "rouge") || kd != "rouge"
        ctx.warns << "_config.yml: #{path}: colours Rouge output only; set kramdown.syntax_highlighter: rouge" if off
      end
      Schema.register(Key.new(name: "code_theme", type: :enum, enum: %w[theme github], message: "must be theme or github (got %{got})",
                              check: rouge))
    end
  end
end
