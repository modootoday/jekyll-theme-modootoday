# frozen_string_literal: true

require "yaml"
require "date"

module Modootoday
  module Check
    # Links that open a new window, and sample links in demo pages.
    # Source: raw <a target="_blank"> without rel="noopener" (error) or without the theme hint (warning; use
    #   {: .mt-new-window} or new_window: true); a non-boolean new_window: (error); in a demo page (front matter
    #   noindex: true) a link or url: that leaves the sample (root path, other site) or is empty (warning).
    # Built site: target="_blank" without rel="noopener" (error) or without aria-describedby (warning); a demo page
    #   link that resolves to the site root (warning: write "#").
    module NewWindow
      BLANK = /<a\b[^>]*\btarget=["']_blank["'][^>]*>/i

      module_function

      def call(ctx, f, text, code)
        r = ctx.rel(f)
        code.each_line.with_index(1) do |l, n|
          l.scan(BLANK) do |a|
            next if a.include?("mt-new-window") || a.include?("data-mt-new-window")
            next ctx.errs << "#{r}:#{n}: target=\"_blank\" without rel=\"noopener\"; add it or use [text](url \"new-window\")" unless a =~ /\brel=["'][^"']*noopener/
            ctx.warns << "#{r}:#{n}: new-window link without the spoken hint; use [text](url \"new-window\") or new_window: true"
          end
        end
        fm = front(text)
        text[/\A---\s*\n.*?\n---/m].to_s.scan(/\bnew_window:\s*([^,}\s]+)/) { ctx.errs << "#{r}: new_window: must be true or false (got #{$1})" unless %w[true false].include?($1) }
        demo(ctx, r, text, code) if fm["noindex"] == true
      end

      def front(text)
        m = text.match(/\A---\s*\n(.*?)\n---/m)
        m ? (YAML.safe_load(m[1], permitted_classes: [Date, Time]) || {}) : {}
      rescue Psych::Exception
        {}
      end

      def demo(ctx, r, text, code)
        urls = code.scan(/(?<!!)\[[^\]]*\]\(([^)]*)\)/).flatten + text.scan(/"url":\s*"([^"]*)"|\burl:\s*"?([^",}\s]*)/).flatten.compact
        urls.each do |u|
          next ctx.warns << "#{r}: demo link with no target; write \"#\" for a sample link" if u.strip.empty?
          next unless u.start_with?("/") || u =~ %r{\A\w+://}
          ctx.warns << "#{r}: demo link #{u} leaves the sample; write \"#\" unless it is the real destination"
        end
      end

      def built(ctx)
        Dir.glob("#{ctx.site}/**/*.html").each do |f|
          t = File.read(f).gsub(%r{<pre\b.*?</pre>}m, "")
          t.scan(BLANK) do |a|
            next ctx.errs << "#{f}: target=\"_blank\" without rel=\"noopener\"" unless a =~ /\brel=["'][^"']*noopener/
            ctx.warns << "#{f}: new-window link without aria-describedby hint" unless a.include?("aria-describedby")
          end
          next unless t.include?('name="robots" content="noindex"') && !t.include?('http-equiv="refresh"')
          t.scan(/<main\b.*<\/main>/m).join.gsub(%r{<nav[^>]*breadcrumb.*?</nav>}m, "").scan(/<a\b[^>]*\bhref="([^"]*)"/) do |(h)|
            ctx.warns << "#{f}: demo link #{h} resolves to the site root; write \"#\" for a sample link" if h =~ %r{\A(/[\w.-]+)?/#?\z}
          end
        end
      end
    end
  end
end
