# frozen_string_literal: true

module Modootoday
  module Check
    # 5. Built site: unconverted Markdown markers in HTML (a chart: paragraph only with modootoday.chart.enabled), CSS
    #    that GitHub Pages' Ruby Sass passes through or leaves undefined, and the size of search.json.
    module BuildOutput
      MARKS = /\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/i

      module_function

      def residue(ctx)
        chart = ctx.mtc.is_a?(Hash) && ctx.mtc["chart"].is_a?(Hash) && ctx.mtc["chart"]["enabled"] == true
        Dir.glob("#{ctx.site}/**/*.html").each do |f|
          t = File.read(f).gsub(%r{<pre\b.*?</pre>}m, "")
          t.scan(%r{<p><code[^>]*>chart:([^<]*)</code></p>}) { unconverted_chart(ctx, f, $1) } if chart
          t = t.gsub(%r{<code\b.*?</code>}m) { |c| c.include?("status:") ? c : "" }
          t.scan(MARKS) { ctx.errs << "#{f}: unconverted alert marker [!#{$1}]" }
          ctx.errs << "#{f}: unconverted status badge (<code>status:)" if t =~ /<code[^>]*>status:/
        end
      end

      # A line with an unknown type or option is already a source error, so only a valid one left as code is reported.
      def unconverted_chart(ctx, f, value)
        words = value.split
        return unless Chart::TYPES.include?(words.first) && (words.drop(1) - Chart::OPTS).empty?
        ctx.errs << "#{f}: unconverted chart `chart:#{value}` (a paragraph with only <code>chart:); put it right before its table"
      end

      SEARCH_WARN = 1_500_000

      # Every visitor downloads the whole index on the first search, so a large one slows the first result.
      def search_index(ctx)
        f = File.join(ctx.site.to_s, "search.json")
        return unless File.file?(f) && File.size(f) > SEARCH_WARN
        ctx.warns << "#{f}: #{(File.size(f) / 1e6).round(1)} MB is over 1.5 MB; lower modootoday.search.words or exclude old pages"
      end

      def css(ctx)
        errs = ctx.errs
        files = Dir.glob("#{ctx.site}/**/*.css").sort
        defined = {}
        files.each do |f|
          t = File.read(f)
          errs << "#{f}: @use/@forward left in built CSS (Ruby Sass passes them through); use @import" if t =~ /@(use|forward)\s/
          errs << "#{f}: @supports selector() in built CSS" if t =~ /@supports\s+(not\s+)?selector\(/
          errs << "#{f}: custom property with a literal Sass variable (write --x: \#{$var})" if t =~ /--[\w-]+:\s*\$/
          t.scan(/(--mt-[\w-]+)\s*:/) { defined[$1] = true }
        end
        Dir.glob("#{ctx.site}/**/*.html").each { |f| File.read(f).scan(%r{<style[^>]*>(.*?)</style>}m) { $1.scan(/(--mt-[\w-]+)\s*:/) { defined[$1] = true } } }
        # A var() with a fallback is a hook (registry/_hooks.scss): never declared on purpose.
        files.each do |f|
          File.read(f).scan(/var\((--mt-[\w-]+)\s*\)/).flatten.uniq.each { |v| errs << "#{f}: var(#{v}) is never defined" unless defined[v] }
        end
      end
    end
  end
end
