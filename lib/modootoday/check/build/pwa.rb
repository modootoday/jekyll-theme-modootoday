# frozen_string_literal: true

require_relative "../../stubs"
require_relative "pwa/manifest"

module Modootoday
  module Check
    # modootoday.pwa.enabled: true: the stubs are in place and current (the plan of modootoday-stubs --pwa --check, so the
    # two never disagree), the built manifest is valid (pwa/manifest.rb) and every theme page links it.
    module Pwa
      HINT = "run modootoday-stubs SRC --pwa --write"
      THEME_PAGE = /<html\b[^>]*\sdata-mt-copy=/
      LINK = /<link rel="manifest" href=/

      module_function

      def call(ctx)
        cfg = ctx.mtc.is_a?(Hash) ? ctx.mtc["pwa"] : nil
        return unless cfg.is_a?(Hash) && cfg["enabled"] == true
        stubs(ctx)
        Manifest.call(ctx)
        links(ctx)
      end

      def stubs(ctx)
        Stubs::Plan.new(Stubs::Source.new(ctx.src), [:pwa], prune: false).changes.each do |c|
          ctx.errs << "#{c.path}: #{c.reason == 'missing' ? 'missing' : 'out of date'}: #{HINT}"
        end
      rescue Stubs::ConfigError, Stubs::DataError => e
        ctx.errs << "modootoday.pwa: #{e.message}"
      end

      # MDN: every page of a multi-page app links the manifest. A site layout or head-meta.html override can drop it.
      def links(ctx)
        Dir.glob("#{ctx.site}/**/*.html").sort.each do |f|
          html = File.read(f)
          next unless html.match?(THEME_PAGE) && !html.match?(LINK)
          ctx.errs << "#{f}: no <link rel=\"manifest\">; a site override of the head drops modootoday/pwa/head.html"
        end
      end
    end
  end
end
