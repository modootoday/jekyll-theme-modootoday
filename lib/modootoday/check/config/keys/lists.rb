# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "lists", type: :map, keys: %w[link_chips titled_items], values: :bool,
                              message: "must be a map of link_chips and titled_items set to true or false"))
    end
  end
end
