# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # modootoday.chart: enabled turns a `chart:<type>` code span before a table into a chart figure (page/chart.rb).
      Schema.register(Key.new(name: "chart", type: :map, keys: %w[enabled], values: :bool, message: "must be a map {enabled: true or false}"))
    end
  end
end
