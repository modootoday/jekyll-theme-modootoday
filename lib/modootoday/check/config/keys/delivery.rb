# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "css", type: :enum, enum: %w[split bundle], message: "must be split or bundle"))
      Schema.register(Key.new(name: "asset_version", type: :enum, enum: ["theme", "build", false],
                              message: "must be theme, build or false (got %{got})"))
    end
  end
end
