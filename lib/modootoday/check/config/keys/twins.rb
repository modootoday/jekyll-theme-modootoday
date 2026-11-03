# frozen_string_literal: true

require_relative "../../../stubs"

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
      # Record sets (modootoday-stubs --records): the settings each one may have and their shapes.
      RECORD_FIELDS = Stubs::Records::FIELDS
      record_sets = lambda do |ctx, path, sets|
        sets.each do |name, set|
          where = "_config.yml: #{path}.#{name}"
          next ctx.errs << "#{where} must be a map of #{RECORD_FIELDS.join(", ")}" unless set.is_a?(Hash) && (set.keys - RECORD_FIELDS).empty?
          ctx.errs << "#{where}.facts must be a list of field names" unless set["facts"].nil? || (set["facts"].is_a?(Array) && set["facts"].all?(String))
          ctx.errs << "#{where}.labels must be a map of field name to label" unless set["labels"].nil? || set["labels"].is_a?(Hash)
          ctx.errs << "#{where}.permalink must contain :key, like /#{name}/:key/" unless set["permalink"].nil? || set["permalink"].to_s.include?(":key")
          ctx.errs << "#{where}.layout must be detail, reference or a detail layout (they render a record)" unless [nil, "detail", "reference", *Layouts::Detail::LAYOUTS].include?(set["layout"])
        end
      end
      Schema.register(Key.new(name: "records", type: :map, check: record_sets, message: "must be a map of record sets (got %{got})"))
    end
  end
end
