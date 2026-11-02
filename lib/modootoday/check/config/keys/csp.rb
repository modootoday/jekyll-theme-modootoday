# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "csp", type: :enum, enum: ["strict", false], message: "must be strict or false (got %{got})"))
    end
  end
end
