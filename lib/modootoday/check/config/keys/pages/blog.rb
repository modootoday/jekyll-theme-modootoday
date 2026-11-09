# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "authors", type: :bool, message: "must be true or false (false hides post bylines)"))
      # Registered so every key has one entry; their shapes are judged by the blog layouts and section checks.
      %w[blog news subscribe].each { |name| Schema.register(Key.new(name: name, type: :any)) }
    end
  end
end
