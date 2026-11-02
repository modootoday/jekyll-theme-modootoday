# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "twins", type: :enum, enum: [true, false, "source"], message: "must be true, false or source (got %{got})"))
    end
  end
end
