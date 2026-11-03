# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # Checks one value against its Key: the type (with enum, sub-keys, value type, required sub-keys or
      # pattern), then the key's own check, which runs only on a value of the right shape.
      module Validate
        BOOL = [true, false].freeze
        SITE_PATH = %r{\A/(\S*/)?\z}
        URL = %r{\Ahttps?://\S+\z}
        WORDING = { bool: "must be true or false", map: "must be a map", list: "must be a list", off_or_map: "must be false or a map" }.freeze

        module_function

        def value(ctx, path, key, v)
          return ctx.errs << "_config.yml: #{path} #{message(key, v)}" unless ok?(key, v)
          key.check&.call(ctx, path, v)
        end

        def ok?(key, v)
          case key.type
          when :bool then BOOL.include?(v)
          when :enum then key.enum.include?(v)
          when :url then v.to_s.match?(key.pattern || URL)
          when :site_path then v.to_s.match?(SITE_PATH)
          when :list then v.is_a?(Array) && (key.pattern.nil? || v.all? { |x| x.to_s.match?(key.pattern) })
          when :map then map?(key, v)
          when :off_or_map then v == false || map?(key, v)
          else raise ArgumentError, "unknown config type #{key.type.inspect} for #{key.name}"
          end
        end

        def map?(key, v)
          return false unless v.is_a?(Hash)
          return false unless key.keys.nil? || (v.keys - key.keys).empty?
          return false unless key.values.nil? || v.values.all? { |x| ok?(Key.new(name: key.name, type: key.values), x) }
          Array(key.required).all? { |k| v[k] }
        end

        def message(key, v) = (key.message || WORDING.fetch(key.type)).sub("%{got}") { v.inspect }
      end
    end
  end
end
