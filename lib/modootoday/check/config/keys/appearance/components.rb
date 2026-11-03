# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      known_names = lambda do |ctx, path, list|
        all = SiteConfig::COMPONENTS
        (list.map(&:to_s) - all).each { |c| ctx.errs << "_config.yml: #{path}: unknown component '#{c}' (known: #{all.join(', ')})" }
      end
      Schema.register(Key.new(name: "components", type: :list, check: known_names))
    end
  end
end
