# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # modootoday.search: what the search.json include indexes (words, collections, fields, exclude) and how chrome/search.js
      # matches (match, compact, results). fallback belongs to the search layout (layouts/shells.rb).
      module Search
        KEYS = %w[words collections fields exclude match compact results fallback].freeze
        MATCH = %w[substring terms].freeze
        FIELD = /\A[A-Za-z_][\w-]*\z/

        module_function

        def errors(map, site_cfg)
          errs = []
          errs << ".words must be a whole number, 0 for no limit (got #{map['words'].inspect})" if map.key?("words") && !count?(map["words"], 0)
          errs << ".results must be a whole number from 1 (got #{map['results'].inspect})" if map.key?("results") && !count?(map["results"], 1)
          errs << ".match must be substring or terms (got #{map['match'].inspect})" if map.key?("match") && !MATCH.include?(map["match"])
          errs << ".compact must be true or false" if map.key?("compact") && ![true, false].include?(map["compact"])
          errs << ".fields must be a list of front matter keys such as [description, tags]" if map.key?("fields") && !list?(map["fields"], FIELD)
          errs << ".exclude must be a list of URL prefixes that start with / (such as /v1/)" if map.key?("exclude") && !list?(map["exclude"], %r{\A/})
          errs.concat(collections(map["collections"], site_cfg)) if map.key?("collections")
          errs + (map.keys - KEYS).map { |k| ": unknown key #{k} (#{KEYS.join(', ')})" }
        end

        def collections(list, site_cfg)
          return [".collections must be a list of collection names"] unless list?(list, /\A\S+\z/)
          defined = site_cfg["collections"]
          names = defined.is_a?(Hash) ? defined.keys : Array(defined)
          list.flat_map do |c|
            next [".collections: posts are always indexed; leave them out"] if c == "posts"
            next [".collections: #{c} is not in collections: of _config.yml"] unless names.map(&:to_s).include?(c)
            output = defined.is_a?(Hash) && defined[c].is_a?(Hash) && defined[c]["output"] == true
            output ? [] : [".collections: #{c} needs output: true, or its documents have no page to link to"]
          end
        end

        def count?(v, min) = v.is_a?(Integer) && v >= min
        def list?(v, pattern) = v.is_a?(Array) && v.all? { |x| x.is_a?(String) && x.match?(pattern) }
      end

      Schema.register(Key.new(name: "search", type: :map, message: "must be a map such as {match: terms, compact: true}",
                              check: ->(ctx, path, v) { Search.errors(v, ctx.site_cfg).each { |e| ctx.errs << "_config.yml: #{path}#{e}" } }))
    end
  end
end
