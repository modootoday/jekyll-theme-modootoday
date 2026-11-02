# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "css", type: :enum, enum: %w[split bundle], message: "must be split or bundle"))
    end
  end
end
