# frozen_string_literal: true

module Modootoday
  module Check
    module Renderers
      module_function

      # Every third-party script or stylesheet in the build must be a declared renderer URL with its SRI hash.
      def built(ctx)
        return unless ctx.site && File.directory?(ctx.site)
        allowed = allowed(ctx.mtc)
        Dir.glob("#{ctx.site}/**/*.html").sort.each { |f| page(ctx, f.delete_prefix("#{ctx.site}/"), File.read(f), allowed) }
      end

      def allowed(mtc) = assets(mtc).values.flatten(1).to_h { |_, src, sri| [src.to_s.strip, sri.to_s.strip] }

      # Each third-party script or stylesheet on one built page.
      def page(ctx, name, html, allowed)
        html.scan(%r{<script\b[^>]*>|<link\b[^>]*>}i) do |tag|
          next if tag.start_with?("<link") && tag !~ /\brel="?stylesheet/i
          u = tag[/\b(?:src|href)="([^"]*)"/i, 1]
          next unless u && u =~ EXTERNAL
          kind = tag.start_with?("<link") ? "stylesheet" : "script"
          next ctx.errs << "#{name}: external #{kind} #{u} is not a declared renderer URL (modootoday.mermaid, modootoday.math, modootoday.chart); self-host it or declare it" unless allowed.key?(u)
          sri = tag[/\bintegrity="([^"]*)"/i, 1]
          ctx.errs << "#{name}: external #{kind} #{u} without integrity=\"…\" (SRI)" if sri.to_s.empty?
          ctx.errs << "#{name}: external #{kind} #{u}: integrity differs from _config.yml" if sri && !allowed[u].empty? && sri != allowed[u]
          ctx.errs << "#{name}: external #{kind} #{u} without crossorigin=\"anonymous\"" unless tag =~ /\bcrossorigin="anonymous"/i
        end
      end
    end
  end
end
