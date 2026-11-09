# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # Registered so every key has one entry; check/config/renderers.rb judges their settings and URLs.
      %w[mermaid math].each { |name| Schema.register(Key.new(name: name, type: :any)) }
    end
  end
end
