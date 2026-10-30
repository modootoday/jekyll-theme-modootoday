# frozen_string_literal: true

module Modootoday
  module Check
    # Optional client-side renderers (modootoday.mermaid, modootoday.math): the settings, ```math notation, and every third-party
    # <script>/<link rel=stylesheet> in the build, which must be a declared renderer URL with its SRI hash.
    module Renderers
      SRI = /\A(sha256|sha384|sha512)-[A-Za-z0-9+\/]+={0,2}( (sha256|sha384|sha512)-[A-Za-z0-9+\/]+={0,2})*\z/
      PINNED = %r{@v?\d+\.\d+(\.\d+)?[^/]*/|/v?\d+\.\d+\.\d+[^/]*/}
      THEMES = %w[auto default dark neutral forest].freeze
      EXTERNAL = %r{\A(https?:)?//}i

      module_function

      MATH_KEYS = %w[enabled engine src css integrity auto_render_src auto_render_integrity inline].freeze
      # Inline $…$ in prose (not $5 or "$ 5", not $$): rendered only with modootoday.math.inline: true.
      DOLLAR = /(?<![\\$\w])\$(?=[^\s$\d])[^$\n]*?[^\s\\$]\$(?![\w$])/

      # name => [[key, src, integrity, integrity key]] for each URL the settings declare (only when enabled)
      def assets(mtc)
        out = {}
        return out unless mtc.is_a?(Hash)
        m = mtc["mermaid"]
        out["mermaid"] = [["src", m["src"], m["integrity"], "integrity"]] if m.is_a?(Hash) && m["enabled"] == true
        x = mtc["math"]
        if x.is_a?(Hash) && x["enabled"] == true
          i = x["integrity"].is_a?(Hash) ? x["integrity"] : {}
          out["math"] = [["src", x["src"], i["js"], "integrity.js"], ["css", x["css"], i["css"], "integrity.css"]]
          out["math"] << ["auto_render_src", x["auto_render_src"], x["auto_render_integrity"], "auto_render_integrity"] if x.key?("auto_render_src")
        end
        out
      end

      def call(ctx)
        settings(ctx)
        notation(ctx)
        built(ctx)
      end

      def settings(ctx)
        mtc, errs = ctx.mtc, ctx.errs
        return unless mtc.is_a?(Hash)
        if mtc.key?("mermaid")
          m = mtc["mermaid"]
          return errs << "_config.yml: modootoday.mermaid must be a map (enabled:, src:, integrity:, theme:)" unless m.is_a?(Hash)
          (m.keys - %w[enabled src integrity theme]).each { |k| errs << "_config.yml: modootoday.mermaid: unknown key '#{k}' (known: enabled, src, integrity, theme)" }
          errs << "_config.yml: modootoday.mermaid.enabled must be true or false" if m.key?("enabled") && ![true, false].include?(m["enabled"])
          errs << "_config.yml: modootoday.mermaid.theme must be #{THEMES.join(', ')}" if m.key?("theme") && !THEMES.include?(m["theme"].to_s)
        end
        math(ctx, mtc["math"]) if mtc.key?("math")
        assets(mtc).each { |name, list| list.each { |key, src, sri, sri_key| url(errs, "modootoday.#{name}.#{key}", src, sri, sri_key) } }
      end

      def math(ctx, x)
        errs = ctx.errs
        return errs << "_config.yml: modootoday.math must be a map (enabled:, src:, css:, integrity: {js:, css:}, auto_render_src:, auto_render_integrity:, inline:)" unless x.is_a?(Hash)
        (x.keys - MATH_KEYS).each { |k| errs << "_config.yml: modootoday.math: unknown key '#{k}' (known: #{MATH_KEYS.join(', ')})" }
        %w[enabled inline].each { |k| errs << "_config.yml: modootoday.math.#{k} must be true or false" if x.key?(k) && ![true, false].include?(x[k]) }
        errs << "_config.yml: modootoday.math.engine must be katex" if x.key?("engine") && x["engine"] != "katex"
        errs << "_config.yml: modootoday.math.integrity must be a map {js: sha384-…, css: sha384-…}" if x.key?("integrity") && !x["integrity"].nil? && !x["integrity"].is_a?(Hash)
        return unless x["enabled"] == true
        ctx.warns << "_config.yml: modootoday.math: without auto_render_src only ```math fences render; $$ blocks#{x['inline'] == true ? ' and inline $…$' : ''} stay TeX source" unless x["auto_render_src"]
      end

      # ```math fences and $$ blocks are the standard notation; inline $…$ renders only with inline: true.
      def notation(ctx)
        x = ctx.mtc.is_a?(Hash) ? ctx.mtc["math"] : nil
        return unless x.is_a?(Hash) && x["enabled"] == true && x["inline"] != true && ctx.respond_to?(:mds)
        ctx.mds.each do |f|
          n = inline_dollar(File.read(f))
          ctx.warns << "#{ctx.rel(f)}:#{n}: inline $…$ stays plain text on this site (modootoday.math.inline is false); use a ```math fence or a $$ block, or set inline: true" if n
        end
      end

      # Line number of the first inline $…$ outside code, or nil.
      def inline_dollar(text)
        fence = nil
        text.each_line.with_index(1) do |l, n|
          if l =~ /\A {0,3}(`{3,}|~{3,})/
            fence = fence ? (l.strip.start_with?(fence) ? nil : fence) : $1
            next
          end
          next if fence || l =~ /\A {4}|\A\t/
          return n if l.gsub(/`+[^`]*`+/, "").gsub("$$", "") =~ DOLLAR
        end
        nil
      end

      # One declared URL: a pinned https URL with an SRI hash, or a site path (/…).
      def url(errs, key, src, sri, sri_key)
        s = src.to_s.strip
        base = key.sub(/\.[^.]+\z/, "")
        return errs << "_config.yml: #{key} is required when #{base}.enabled is true (a pinned https URL with integrity, or a site path such as /assets/…)" if s.empty?
        if s =~ EXTERNAL
          return errs << "_config.yml: #{key}: use https:// (got #{s})" unless s.start_with?("https://")
          errs << "_config.yml: #{key}: pin an exact version in the URL (e.g. …@11.4.1/…), not a range or latest (got #{s})" unless s =~ PINNED && s !~ /@latest\b/
          return errs << "_config.yml: #{base}: #{key.split('.').last} is an https URL, so #{sri_key} (an SRI hash such as sha384-…) is required; nothing loads without it" if sri.to_s.strip.empty?
        elsif !s.start_with?("/")
          return errs << "_config.yml: #{key}: must be an https URL or a site path starting with / (got #{s})"
        end
        errs << "_config.yml: #{base}.#{sri_key}: not an SRI hash (sha256-, sha384- or sha512- followed by base64)" unless sri.to_s.strip.empty? || sri.to_s.strip =~ SRI
      end

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
          next ctx.errs << "#{name}: external #{kind} #{u} is not a declared renderer URL (modootoday.mermaid, modootoday.math); self-host it or declare it" unless allowed.key?(u)
          sri = tag[/\bintegrity="([^"]*)"/i, 1]
          ctx.errs << "#{name}: external #{kind} #{u} without integrity=\"…\" (SRI)" if sri.to_s.empty?
          ctx.errs << "#{name}: external #{kind} #{u}: integrity differs from _config.yml" if sri && !allowed[u].empty? && sri != allowed[u]
          ctx.errs << "#{name}: external #{kind} #{u} without crossorigin=\"anonymous\"" unless tag =~ /\bcrossorigin="anonymous"/i
        end
      end
    end
  end
end
