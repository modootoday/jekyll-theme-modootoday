# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "banner", type: :map, required: %w[text], message: "must be a map with text: (and optional url:, link:)"))
      Schema.register(Key.new(name: "sidebar", type: :enum, enum: [true, false, "auto"], message: "must be auto, true or false"))
    end
  end
end
