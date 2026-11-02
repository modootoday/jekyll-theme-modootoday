# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # Declarative shape of one modootoday: key. message overrides the type's wording; %{got} is the value.
      Key = Struct.new(:name, :type, :enum, :keys, :values, :required, :pattern, :message, :check, keyword_init: true)

      # The registered keys, validated in registration order (config/keys.rb), which is the report order.
      module Schema
        module_function

        def keys = (@keys ||= {})
        def register(key) = keys[key.name] = key

        def validate(ctx)
          mtc = ctx.mtc
          keys.each_value { |key| Validate.value(ctx, "modootoday.#{key.name}", key, mtc[key.name]) if mtc.key?(key.name) }
        end
      end
    end
  end
end
