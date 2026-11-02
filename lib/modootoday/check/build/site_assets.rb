# frozen_string_literal: true

module Modootoday
  module Check
    # The site's own files the theme links (site_css, preload) from _config.yml and front matter: front matter takes the
    # same shapes as the settings, and each file must be in the build, because a missing sheet or font fails silently.
    module SiteAssets
      module_function

      def call(ctx)
        mtc = ctx.mtc.is_a?(Hash) ? ctx.mtc : {}
        present_all(ctx, "_config.yml", "modootoday.", mtc)
        ctx.mds.each do |f|
          fm = (Markdown.fm(File.read(f)) rescue {})
          next unless fm.is_a?(Hash) && (fm.key?("site_css") || fm.key?("preload"))
          r = ctx.rel(f)
          next unless shape_ok?(ctx, r, fm)
          present_all(ctx, r, "", fm)
        end
      end

      def shape_ok?(ctx, r, fm)
        errs = []
        errs += list_errors("site_css", fm["site_css"]) { |v| Config::Delivery.site_css_errors(v).map { |e| "site_css: #{e}" } }
        errs += list_errors("preload", fm["preload"]) { |v| Config::Delivery.preload_errors(v).map { |e| "preload#{e}" } }
        errs.each { |e| ctx.errs << "#{r}: front matter #{e}" }
        errs.empty?
      end

      def list_errors(key, v)
        return [] if v.nil?
        return ["#{key} must be a list"] unless v.is_a?(Array)
        yield v
      end

      def present_all(ctx, where, prefix, data)
        return unless ctx.site && File.directory?(ctx.site)
        Array(data["site_css"]).grep(String).each { |p| present(ctx, where, "#{prefix}site_css", p) }
        Array(data["preload"]).grep(Hash).each { |h| present(ctx, where, "#{prefix}preload", h["href"]) if h["href"].is_a?(String) }
      end

      def present(ctx, where, key, path)
        return unless path.match?(Config::Delivery::SITE_FILE)
        file = File.join(ctx.site, path.split(/[?#]/).first)
        ctx.errs << "#{where}: #{key} #{path} is not in the build" unless File.file?(file)
      end
    end
  end
end
