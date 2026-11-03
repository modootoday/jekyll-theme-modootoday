# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "twins", type: :enum, enum: [true, false, "source"], message: "must be true, false or source (got %{got})"))
      # In source mode a page without front matter is already copied raw to /<page>.md, the md alias URL.
      no_md_in_source = lambda do |ctx, path, v|
        ctx.errs << "_config.yml: #{path}.md cannot be used with twins: source (a page without front matter is already at /<page>.md)" if v["md"] && ctx.source_mode?
      end
      Schema.register(Key.new(name: "aliases", type: :map, keys: %w[md html], values: :bool, check: no_md_in_source,
                              message: "must be a map of md and html, each true or false (got %{got})"))
    end
  end
end
