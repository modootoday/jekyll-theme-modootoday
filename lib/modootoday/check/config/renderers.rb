# frozen_string_literal: true

module Modootoday
  module Check
    # Optional client-side renderers (modootoday.mermaid, modootoday.math, modootoday.chart): the settings here, ```math
    # notation in page/math_notation.rb, and every third-party <script>/<link rel=stylesheet> in build/third_party.rb.
    module Renderers
      SRI = /\A(sha256|sha384|sha512)-[A-Za-z0-9+\/]+={0,2}( (sha256|sha384|sha512)-[A-Za-z0-9+\/]+={0,2})*\z/
      PINNED = %r{@v?\d+\.\d+(\.\d+)?[^/]*/|/v?\d+\.\d+\.\d+[^/]*/}
      THEMES = %w[auto default dark neutral forest].freeze
      EXTERNAL = %r{\A(https?:)?//}i

      module_function

      MATH_KEYS = %w[enabled engine mode base src css integrity auto_render_src auto_render_integrity inline].freeze
      MATH_MODES = %w[client static].freeze
      # What math.base names, laid out as the KaTeX package's dist/ folder.
      MATH_BASE = { "src" => "katex.min.js", "css" => "katex.min.css", "auto_render_src" => "contrib/auto-render.min.js" }.freeze

      # math.src, css and auto_render_src: each key's own value, else the file under math.base.
      def math_urls(x)
        base = x["base"].to_s
        MATH_BASE.to_h { |k, f| [k, x[k] || (base.empty? ? nil : base + f)] }
      end

      # math.mode: static, not switched off: blocks come from _data/math (page/figures/math_static.rb), no loader.
      def static_math?(mtc)
        x = mtc.is_a?(Hash) ? mtc["math"] : nil
        x.is_a?(Hash) && x["mode"] == "static" && x["enabled"] != false
      end

      # name => [[key, src, integrity, integrity key]] for each URL the settings declare (only when enabled; static
      # math declares only its stylesheet, which loads with KaTeX HTML output)
      def assets(mtc)
        out = {}
        return out unless mtc.is_a?(Hash)
        m = mtc["mermaid"]
        out["mermaid"] = [["src", m["src"], m["integrity"], "integrity"]] if m.is_a?(Hash) && m["enabled"] == true
        # Charts without src stay tables, so only a declared src is checked.
        c = mtc["chart"]
        out["chart"] = [["src", c["src"], c["integrity"], "integrity"]] if c.is_a?(Hash) && c["enabled"] == true && c.key?("src")
        x = mtc["math"]
        return out unless x.is_a?(Hash) && (x["enabled"] == true || static_math?(mtc))
        i = x["integrity"].is_a?(Hash) ? x["integrity"] : {}
        u = math_urls(x)
        css = ["css", u["css"], i["css"], "integrity.css"]
        return out.merge("math" => u["css"] ? [css] : []) if static_math?(mtc)
        out["math"] = [["src", u["src"], i["js"], "integrity.js"], css]
        out["math"] << ["auto_render_src", u["auto_render_src"], x["auto_render_integrity"], "auto_render_integrity"] if u["auto_render_src"] || x.key?("auto_render_src")
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
        return errs << "_config.yml: modootoday.math must be a map (enabled:, mode:, base:, src:, css:, integrity: {js:, css:}, auto_render_src:, auto_render_integrity:, inline:)" unless x.is_a?(Hash)
        (x.keys - MATH_KEYS).each { |k| errs << "_config.yml: modootoday.math: unknown key '#{k}' (known: #{MATH_KEYS.join(', ')})" }
        %w[enabled inline].each { |k| errs << "_config.yml: modootoday.math.#{k} must be true or false" if x.key?(k) && ![true, false].include?(x[k]) }
        errs << "_config.yml: modootoday.math.engine must be katex" if x.key?("engine") && x["engine"] != "katex"
        errs << "_config.yml: modootoday.math.mode must be #{MATH_MODES.join(' or ')} (got #{x['mode'].inspect})" if x.key?("mode") && !MATH_MODES.include?(x["mode"])
        errs << "_config.yml: modootoday.math.base must be a site path like /assets/vendor/katex/ (starts and ends with /)" if x.key?("base") && !x["base"].to_s.match?(Config::Validate::SITE_PATH)
        errs << "_config.yml: modootoday.math.integrity must be a map {js: sha384-…, css: sha384-…}" if x.key?("integrity") && !x["integrity"].nil? && !x["integrity"].is_a?(Hash)
        return errs << "_config.yml: modootoday.math: mode: static cannot render inline $…$ ahead of time; remove inline: true and write each formula as a $$ block or a ```math fence" if x["mode"] == "static" && x["inline"] == true
        return unless x["enabled"] == true && x["mode"] != "static"
        ctx.warns << "_config.yml: modootoday.math: without auto_render_src only ```math fences render; $$ blocks#{x['inline'] == true ? ' and inline $…$' : ''} stay TeX source" unless math_urls(x)["auto_render_src"]
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
    end
  end
end
