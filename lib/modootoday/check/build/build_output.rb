# frozen_string_literal: true

module Modootoday
  module Check
    # 5. Built site: unconverted Markdown markers in HTML, and CSS that GitHub Pages' Ruby Sass
    #    passes through or leaves undefined.
    module BuildOutput
      MARKS = /\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/i

      module_function

      def residue(ctx)
        Dir.glob("#{ctx.site}/**/*.html").each do |f|
          t = File.read(f)
          t = t.gsub(%r{<pre\b.*?</pre>}m, "").gsub(%r{<code\b.*?</code>}m) { |c| c.include?("status:") ? c : "" }
          t.scan(MARKS) { ctx.errs << "#{f}: unconverted alert marker [!#{$1}]" }
          ctx.errs << "#{f}: unconverted status badge (<code>status:)" if t =~ /<code[^>]*>status:/
        end
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
        files.each do |f|
          File.read(f).scan(/var\((--mt-[\w-]+)/).flatten.uniq.each { |v| errs << "#{f}: var(#{v}) is never defined" unless defined[v] }
        end
      end
    end
  end
end
