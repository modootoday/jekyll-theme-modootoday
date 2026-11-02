# frozen_string_literal: true

module Modootoday
  module Check
    # The site's token hook _sass/modootoday/_site.scss (the token bridge): only the three override maps, and only
    # token names the theme defines, so a typo fails here instead of emitting a custom property nothing reads.
    module SiteHook
      HOOK = "_sass/modootoday/_site.scss"
      SEMANTIC_SCSS = File.expand_path("../../../../_sass/modootoday/tokens/_semantic.scss", __dir__)
      MAPS = { "mt-overrides-base" => "mt-base", "mt-overrides" => "mt-light", "mt-overrides-dark" => "mt-dark" }.freeze

      module_function

      def call(ctx)
        file = File.join(ctx.src, HOOK)
        return unless File.file?(file)
        statements(File.read(file)).each do |line, text|
          name, body = text.match(/\A\$([\w-]+)\s*:\s*\((.*)\)\s*(!default\s*)?\z/m)&.captures
          next ctx.errs << "#{HOOK}:#{line}: only $mt-overrides-base, $mt-overrides and $mt-overrides-dark maps belong here; put rules in a site_css sheet" unless MAPS.key?(name)
          known = theme_keys(MAPS[name])
          map_keys(body).each do |k|
            ctx.errs << "#{HOOK}:#{line}: $#{name}: unknown token #{k} (#{known.join(', ')})" unless known.include?(k)
          end
        end
      end

      # Top-level statements with the line each starts on; comments are blanked first, keeping line numbers.
      def statements(src)
        src = src.gsub(%r{/\*.*?\*/}m) { |c| c.gsub(/[^\n]/, " ") }.gsub(%r{//[^\n]*}, "")
        out, cur, depth, start = [], +"", 0, nil
        src.each_char.with_index do |c, i|
          start ||= src[0, i].count("\n") + 1 unless c.match?(/\s/)
          depth += 1 if c == "("
          depth -= 1 if c == ")"
          next cur << c unless c == ";" && depth.zero?
          out << [start, cur.strip] unless cur.strip.empty?
          cur, start = +"", nil
        end
        out << [start, cur.strip] unless cur.strip.empty?
        out
      end

      def map_keys(body) = split_top(body).filter_map { |part| part[/\A\s*["']?([\w-]+)["']?\s*:/, 1] }

      def split_top(body)
        parts, cur, depth = [], +"", 0
        body.each_char do |c|
          depth += 1 if c == "("
          depth -= 1 if c == ")"
          next cur << c unless c == "," && depth.zero?
          parts << cur
          cur = +""
        end
        parts << cur
      end

      def theme_keys(map)
        (@theme_keys ||= {})[map] ||= begin
          body = File.read(SEMANTIC_SCSS)[/\$#{map}:\s*\((.*?)\n\)\s*!default;/m, 1].to_s.gsub(%r{//[^\n]*}, "")
          map_keys(body)
        end
      end
    end
  end
end
