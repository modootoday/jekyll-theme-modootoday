# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "color_scheme", type: :enum, enum: %w[auto auto-dark auto-light light dark],
                              message: "must be auto, auto-dark, auto-light, light or dark (got %{got})"))
    end
  end
end
