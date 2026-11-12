# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # text: shows as written; without it release: latest (site.github) or {version, url} fills the release line.
      banner = lambda do |ctx, path, v|
        release = v["release"]
        next ctx.errs << "_config.yml: #{path} needs text: or release: (latest, or {version, url})" if v["text"].nil? && release.nil?
        next if release.nil?
        ok = release == "latest" || (release.is_a?(Hash) && release["version"].is_a?(String) && (release.keys - %w[version url]).empty?)
        next ctx.errs << "_config.yml: #{path}.release must be latest or a map {version, url} (got #{release.inspect})" unless ok
        GITHUB_SOURCE.call(ctx, "#{path}.release", release)
      end
      Schema.register(Key.new(name: "banner", type: :map, check: banner, message: "must be a map with text: (and optional url:, link:) or release:"))
      Schema.register(Key.new(name: "header", type: :map, keys: %w[compact_title], values: :bool,
                              message: "must be a map with compact_title: set to true or false"))
      Schema.register(Key.new(name: "nav", type: :off_or_name, message: "must be the name of a _data/nav file, or false (no list of titled pages)"))
      Schema.register(Key.new(name: "sidebar", type: :enum, enum: [true, false, "auto"], message: "must be auto, true or false"))
      Schema.register(Key.new(name: "viewport_fit", type: :enum, enum: %w[cover auto], message: "must be cover or auto (got %{got})"))
    end
  end
end
