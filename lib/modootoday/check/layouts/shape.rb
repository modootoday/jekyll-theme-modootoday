# frozen_string_literal: true

module Modootoday
  module Check
    module Layouts
      # Shape helpers shared by the layout contracts: lists of maps, required keys, dates and URLs.
      module Shape
        module_function

        def text?(v) = v.is_a?(String) && !v.strip.empty?
        def url?(v) = v.is_a?(String) && v.match?(%r{\A(/|https?://|mailto:|tel:|#)})
        def date?(v) = v.is_a?(Date) || v.is_a?(Time) || (v.is_a?(String) && (Time.parse(v) rescue false))

        # A list of maps; each map needs one of `any` keys (e.g. title or name). Yields (item, index) for more checks.
        def list(errs, where, key, val, any: %w[title], optional: true)
          return errs << "#{where}: #{key} is required" if val.nil? && !optional
          return if val.nil?
          return errs << "#{where}: #{key} must be a list" unless val.is_a?(Array)
          val.each_with_index do |it, i|
            next errs << "#{where}: #{key}[#{i}] must be a map" unless it.is_a?(Hash)
            errs << "#{where}: #{key}[#{i}] needs #{any.join(' or ')}" unless any.empty? || any.any? { |k| text?(it[k]) || it[k].is_a?(Numeric) }
            %w[url image].each { |k| errs << "#{where}: #{key}[#{i}].#{k} must be a site path or a full URL" if it.key?(k) && !url?(it[k]) }
            yield it, i if block_given?
          end
        end

        def one_of(errs, where, key, val, allowed)
          errs << "#{where}: #{key} must be one of #{allowed.join(', ')} (got #{val.inspect})" unless val.nil? || allowed.include?(val)
        end

        def need_date(errs, where, key, val, optional: false)
          return if val.nil? && optional
          errs << "#{where}: #{key} must be a date (YYYY-MM-DD or YYYY-MM-DD HH:MM)" unless date?(val)
        end
      end
    end
  end
end
