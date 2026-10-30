# frozen_string_literal: true

module Modootoday
  module Check
    module Layouts
      # directory and its presets: items: (or data: <file in _data>), preset:, filter: <item field> or false.
      module Directory
        PRESETS = %w[cards portfolio team jobs events sponsors integrations].freeze
        LAYOUTS = %w[directory portfolio team jobs events sponsors integrations].freeze

        module_function

        def call(errs, where, fm, ctx)
          Shape.one_of(errs, where, "preset", fm["preset"], PRESETS)
          errs << "#{where}: filter must be an item field name or false" unless fm["filter"].nil? || fm["filter"] == false || fm["filter"].is_a?(String)
          items = items(errs, where, fm, ctx)
          return if items.nil?
          events = fm["layout"] == "events" || fm["preset"] == "events"
          Shape.list(errs, where, "items", items, any: %w[title name]) do |it, i|
            Shape.need_date(errs, where, "items[#{i}].date", it["date"], optional: !events)
            Shape.need_date(errs, where, "items[#{i}].end", it["end"], optional: true)
          end
        end

        def items(errs, where, fm, ctx)
          return fm["items"] if fm.key?("items")
          return errs << "#{where}: set items: (a list) or data: (a file in _data)" && nil unless fm["data"]
          f = Dir.glob("#{ctx.src}/_data/#{fm['data']}.{yml,yaml,json}").first
          return errs << "#{where}: data: #{fm['data']} has no file in _data" && nil unless f
          d = YAML.safe_load(File.read(f), permitted_classes: [Date, Time])
          d.is_a?(Hash) ? d["items"] : d
        end
      end
    end
  end
end
