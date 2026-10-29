# frozen_string_literal: true

require_relative "slots"

module Modootoday
  module Check
    # _data/components.yml: the registry's own shape (keys, slot rules, parts against api.md)
    # and the i18n keys it declares.
    module Registry
      REG_KEYS = %w[params i18n slots parts].freeze
      RULE_KEYS = %w[required min max].freeze

      module_function

      def call(ctx)
        errs = ctx.errs
        api_md = "#{ctx.src}/api.md"
        api_codes = File.exist?(api_md) && (tbl = File.read(api_md)[/^## Component structure\n.*?(?=^## )/m]) ? tbl.scan(/`([^`]+)`/).flatten.map { |x| x.gsub("\\|", "|") } : nil
        (ctx.comps.is_a?(Hash) ? ctx.comps : {}).each do |c, spec|
          where = "_data/components.yml: #{c}"
          next if spec.nil?
          next errs << "#{where} must be a map (#{REG_KEYS.join(', ')})" unless spec.is_a?(Hash)
          (spec.keys - REG_KEYS).each { |k| errs << "#{where}: unknown key '#{k}' (known: #{REG_KEYS.join(', ')})" }
          slots(errs, where, spec["slots"]) if spec.key?("slots")
          errs << "#{where}.params must be a map of param name -> {allowed, required}" if spec.key?("params") && !spec["params"].is_a?(Hash)
          parts(errs, where, spec["parts"], api_codes) if spec.key?("parts")
        end
      end

      def slots(errs, where, slots)
        forms = slots.is_a?(Array) ? slots : [slots]
        errs << "#{where}.slots: a list of alternative forms needs at least 2 maps" if slots.is_a?(Array) && forms.size < 2
        forms.each_with_index do |form, fi|
          fw = slots.is_a?(Array) ? "#{where}.slots[#{fi}]" : "#{where}.slots"
          next errs << "#{fw} must be a map of slot name -> {required, min, max}" unless form.is_a?(Hash)
          form.each do |name, rule|
            next errs << "#{fw}: unknown slot '#{name}' (known: #{Slots.names.join(', ')})" unless Slots.known?(name)
            next if rule.nil?
            next errs << "#{fw}.#{name} must be a map of required, min, max" unless rule.is_a?(Hash)
            (rule.keys - RULE_KEYS).each { |k| errs << "#{fw}.#{name}: unknown key '#{k}' (known: #{RULE_KEYS.join(', ')})" }
            errs << "#{fw}.#{name}.required must be true or false" if rule.key?("required") && ![true, false].include?(rule["required"])
            %w[min max].each { |k| errs << "#{fw}.#{name}.#{k} must be a whole number >= 0" if rule.key?(k) && !(rule[k].is_a?(Integer) && rule[k] >= 0) }
            mn = rule["min"].is_a?(Integer) ? rule["min"] : (rule["required"] == true ? 1 : nil)
            errs << "#{fw}.#{name}: min #{mn} is greater than max #{rule['max']}" if mn && rule["max"].is_a?(Integer) && mn > rule["max"]
          end
        end
      end

      def parts(errs, where, parts, api_codes)
        return errs << "#{where}.parts must be a list of CSS selectors" unless parts.is_a?(Array) && parts.all? { |x| x.is_a?(String) && !x.strip.empty? }
        parts.each do |sel|
          errs << "#{where}.parts: '#{sel}' does not look like a CSS selector" unless sel.match?(/\A[\w\s.#\[\]=|"'>+~:()*-]+\z/)
          errs << "#{where}.parts: '#{sel}' is not in the Component structure table of api.md" if api_codes && !api_codes.include?(sel)
        end
      end

      # Every i18n key a component declares exists in every _data/i18n/<lang>.yml or the theme catalog for that language.
      def i18n_keys(ctx)
        return unless ctx.comps
        dig = ->(h, key) { key.split(".").reduce(h) { |a, k| a.is_a?(Hash) ? a[k] : nil } }
        ctx.comps.each do |name, spec|
          Array(spec && spec["i18n"]).each do |key|
            ctx.i18n.each { |lang, h| ctx.errs << "_data/i18n/#{lang}.yml: missing key '#{key}' (component #{name})" if dig[h, key].nil? && !I18n.theme_keys(lang).include?(key) }
          end
        end
      end
    end
  end
end
