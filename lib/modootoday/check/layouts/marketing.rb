# frozen_string_literal: true

module Modootoday
  module Check
    module Layouts
      # Marketing layouts (feature, pricing, download, brand, links, contact): the lists each one reads from front matter.
      module Marketing
        LAYOUTS = %w[feature pricing download brand links contact].freeze
        HEX = /\A#(\h{3}|\h{6})\z/
        FIELDS = %w[name email message].freeze

        module_function

        def call(errs, where, fm, _ctx)
          w = where
          link_list(errs, w, "actions", fm["actions"])
          case fm["layout"]
          when "feature" then Shape.list(errs, w, "features", fm["features"])
          when "pricing" then pricing(errs, w, fm)
          when "download"
            Shape.list(errs, w, "downloads", fm["downloads"], any: %w[label], optional: false) { |d, i| need_url(errs, w, "downloads[#{i}].url", d["url"]) }
          when "brand" then brand(errs, w, fm)
          when "links" then link_list(errs, w, "links", fm["links"], optional: false)
          when "contact" then contact(errs, w, fm)
          end
        end

        def need_url(errs, where, key, v) = (errs << "#{where}: #{key} must be a site path or a full URL" unless Shape.url?(v))

        def link_list(errs, where, key, val, optional: true)
          Shape.list(errs, where, key, val, any: %w[label], optional: optional) { |l, i| need_url(errs, where, "#{key}[#{i}].url", l["url"]) }
        end

        def pricing(errs, where, fm)
          plans = fm["plans"]
          Shape.list(errs, where, "plans", plans, any: %w[name], optional: false) do |p, i|
            errs << "#{where}: plans[#{i}].monthly is required" if p["monthly"].nil?
            errs << "#{where}: plans[#{i}].features must be a list" unless p["features"].nil? || p["features"].is_a?(Array)
          end
          return unless plans.is_a?(Array)
          y = plans.count { |p| p.is_a?(Hash) && !p["yearly"].nil? }
          errs << "#{where}: set yearly on every plan or on none (#{y} of #{plans.size})" unless [0, plans.size].include?(y)
          errs << "#{where}: only one plan can be recommended" if plans.count { |p| p.is_a?(Hash) && p["recommended"] } > 1
        end

        def brand(errs, where, fm)
          Shape.list(errs, where, "colors", fm["colors"], any: %w[name]) do |c, i|
            errs << "#{where}: colors[#{i}].hex must be #rgb or #rrggbb" unless c["hex"].is_a?(String) && c["hex"].match?(HEX)
          end
          Shape.list(errs, where, "assets", fm["assets"], any: %w[label]) { |a, i| need_url(errs, where, "assets[#{i}].url", a["url"]) }
        end

        def contact(errs, where, fm)
          Shape.list(errs, where, "contacts", fm["contacts"], any: %w[label])
          f = fm["form"]
          return if f.nil?
          return errs << "#{where}: form must be a map with action (an https URL)" unless f.is_a?(Hash) && f["action"].to_s.start_with?("https://")
          fl = f["fields"].is_a?(String) ? f["fields"].split(",") : f["fields"]
          (Array(fl) - FIELDS).each { |x| errs << "#{where}: form.fields has unknown field '#{x}' (known: #{FIELDS.join(', ')})" }
        end
      end
    end
  end
end
