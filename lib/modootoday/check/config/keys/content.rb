# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "lists", type: :map, keys: %w[link_chips titled_items], values: :bool,
                              message: "must be a map of link_chips and titled_items set to true or false"))

      site_paths = lambda do |ctx, path, map|
        map.each do |k, v|
          ctx.errs << "_config.yml: #{path}.#{k} must be a site path like /#{k}/ (starts and ends with /)" unless Validate.ok?(Key.new(name: k, type: :site_path), v)
        end
      end
      Schema.register(Key.new(name: "archive", type: :map, keys: %w[tags categories],
                              message: "must be a map with tags: and/or categories: (archive page URLs)", check: site_paths))
    end
  end
end
