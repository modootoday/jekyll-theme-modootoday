# frozen_string_literal: true

module Modootoday
  module Check
    # script: and poster: on hero: or a sections: item. script: names a modootoday.scripts entry; poster: is a site path in
    # the source or the build, with width and height so its box is reserved before it loads (no layout shift). Neither
    # goes with visual: code, whose column holds the code block.
    module HeroScript
      POSTER_KEYS = %w[path srcset sizes width height].freeze

      module_function

      def call(ctx, r, secs, hero)
        items = secs.each_with_index.map { |s, i| [s, "sections[#{i}]"] }
        items << [hero, "hero"] if hero.is_a?(Hash)
        mtc = ctx.mtc.is_a?(Hash) ? ctx.mtc : {}
        names = mtc["scripts"].is_a?(Hash) ? mtc["scripts"].keys : []
        items.each do |s, where|
          next unless s.is_a?(Hash) && (s.key?("script") || s.key?("poster"))
          w = "#{r}: #{where}"
          ctx.errs << "#{w}: script: and poster: do not go with visual: code" if s["visual"] == "code"
          ctx.errs << "#{w}.script: #{s['script'].inspect} is not in modootoday.scripts (_config.yml)" if s.key?("script") && !names.include?(s["script"])
          poster(ctx, w, s["poster"]) if s.key?("poster")
        end
      end

      def poster(ctx, w, v)
        path = v.is_a?(Hash) ? v["path"] : v
        return ctx.errs << "#{w}.poster must be a site path or {path, width, height} (got #{v.inspect})" unless path.is_a?(String) && path.match?(Config::Delivery::SITE_FILE)
        sized = v.is_a?(Hash) && [v["width"], v["height"]].all? { |n| n.is_a?(Integer) && n.positive? }
        ctx.errs << "#{w}.poster needs width and height in pixels, so its box is kept before the image loads" unless sized
        (v.is_a?(Hash) ? v.keys - POSTER_KEYS : []).each { |k| ctx.errs << "#{w}.poster: unknown key #{k} (#{POSTER_KEYS.join(', ')})" }
        file = path.split(/[?#]/).first
        found = [ctx.src, ctx.site].compact.any? { |d| File.file?(File.join(d, file)) }
        ctx.errs << "#{w}.poster: #{file} not found in the site" unless found
      end
    end
  end
end
