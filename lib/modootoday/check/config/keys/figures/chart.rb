# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # modootoday.chart: enabled turns a `chart:<type>` code span before a table into a chart figure (page/chart.rb);
      # src and integrity name the site's Chart.js, checked with the other renderer URLs (config/renderers.rb).
      CHART_KEYS = %w[enabled src integrity].freeze
      chart = lambda do |ctx, path, v|
        (v.keys - CHART_KEYS).each { |k| ctx.errs << "_config.yml: #{path}: unknown key '#{k}' (known: #{CHART_KEYS.join(', ')})" }
        ctx.errs << "_config.yml: #{path}.enabled must be true or false" if v.key?("enabled") && !Validate::BOOL.include?(v["enabled"])
      end
      Schema.register(Key.new(name: "chart", type: :map, message: "must be a map (enabled:, src:, integrity:)", check: chart))
    end
  end
end
