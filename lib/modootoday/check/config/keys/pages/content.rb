# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "lists", type: :map, keys: %w[link_chips titled_items], values: :bool,
                              message: "must be a map of link_chips and titled_items set to true or false"))
      Schema.register(Key.new(name: "external_links", type: :map, keys: %w[new_window icon], values: :bool,
                              message: "must be a map of new_window and icon set to true or false"))
      anchor_on = lambda do |ctx, path, v|
        list = ctx.mtc["components"]
        next unless v == true && list.is_a?(Array) && !list.map(&:to_s).include?("anchor")
        ctx.warns << "_config.yml: #{path}: true has no effect while modootoday.components leaves out anchor"
      end
      Schema.register(Key.new(name: "heading_anchors", type: :bool, check: anchor_on,
                              message: "must be true or false (true links each ## and ### heading to itself)"))

      site_paths = lambda do |ctx, path, map|
        map.each do |k, v|
          ctx.errs << "_config.yml: #{path}.#{k} must be a site path like /#{k}/ (starts and ends with /)" unless Validate.ok?(Key.new(name: k, type: :site_path), v)
        end
      end
      Schema.register(Key.new(name: "archive", type: :map, keys: %w[tags categories],
                              message: "must be a map with tags: and/or categories: (archive page URLs)", check: site_paths))

      # Only the keys the checker reads are judged; the JSON-LD includes ignore the rest.
      faq = lambda do |ctx, path, v|
        next unless v.is_a?(Hash) && v.key?("faq") && !["auto", false].include?(v["faq"])
        ctx.errs << "_config.yml: #{path}.faq must be auto or false (got #{v['faq'].inspect})"
      end
      Schema.register(Key.new(name: "schema", type: :off_or_map, check: faq))
    end
  end
end
