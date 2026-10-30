# frozen_string_literal: true

module Modootoday
  module Check
    # The modootoday: settings in the site's _config.yml.
    module SiteConfig
      COMPONENTS = %w[callout badge hero cta card tabs code-copy nav sidebar page-actions pagination theme-toggle breadcrumb toc accordion steps figure timeline kbd search code footnotes progress embed banner filetree details faq params linkcards quote gallery pricing subscribe split loading].freeze
      SEMANTIC = %w[background foreground muted muted-foreground card card-foreground primary primary-foreground brand accent
                    accent-foreground border ring note tip important warning caution status-available status-partial
                    status-planned font-sans font-mono font-size line-height measure space radius].freeze

      module_function

      # twins: source needs Jekyll's raw copies of front-matter-less pages.
      def source_mode(ctx)
        return unless ctx.source_mode?
        cfg = ctx.site_cfg
        of = cfg["optional_front_matter"] || {}
        ctx.errs << "_config.yml: modootoday.twins: source needs the raw copies; remove optional_front_matter.remove_originals" if of.is_a?(Hash) && of["remove_originals"] == true
        ctx.errs << "_config.yml: modootoday.twins: source conflicts with require_front_matter: true" if cfg["require_front_matter"] == true
      end

      def call(ctx)
        mtc, errs = ctx.mtc, ctx.errs
        return errs << "_config.yml: modootoday: must be a map" if mtc && !mtc.is_a?(Hash)
        return unless mtc.is_a?(Hash)
        enums(mtc, errs)
        full_languages(mtc, errs)
        if mtc.key?("archive")
          a = mtc["archive"]
          if !a.is_a?(Hash) || !(a.keys - %w[tags categories]).empty?
            errs << "_config.yml: modootoday.archive must be a map with tags: and/or categories: (archive page URLs)"
          else
            a.each { |k, v| errs << "_config.yml: modootoday.archive.#{k} must be a site path like /#{k}/ (starts and ends with /)" unless v.to_s =~ %r{\A/(\S*/)?\z} }
          end
        end
        errs << "_config.yml: modootoday.edit_url must be an http(s) URL ending in / (page.path is appended)" if mtc.key?("edit_url") && mtc["edit_url"].to_s !~ %r{\Ahttps?://\S+/\z}
        ctx.warns << "_config.yml: modootoday.feed: true links /feed.xml; add jekyll-feed to plugins" if mtc["feed"] == true && !Array(ctx.site_cfg["plugins"]).map(&:to_s).include?("jekyll-feed")
        %w[css_layers badges seo hreflang feed page_actions back_to_top loading].each { |k| errs << "_config.yml: modootoday.#{k} must be true or false" if mtc.key?(k) && ![true, false].include?(mtc[k]) }
        errs << "_config.yml: modootoday.css must be split or bundle" if mtc.key?("css") && !%w[split bundle].include?(mtc["css"])
        errs << "_config.yml: modootoday.banner must be a map with text: (and optional url:, link:)" if mtc.key?("banner") && !(mtc["banner"].is_a?(Hash) && mtc["banner"]["text"])
        errs << "_config.yml: modootoday.sidebar must be auto, true or false" if mtc.key?("sidebar") && ![true, false, "auto"].include?(mtc["sidebar"])
        if mtc.key?("components")
          list = mtc["components"].is_a?(Array) ? mtc["components"] : (errs << "_config.yml: modootoday.components must be a list"; [])
          (list.map(&:to_s) - COMPONENTS).each { |c| errs << "_config.yml: modootoday.components: unknown component '#{c}' (known: #{COMPONENTS.join(', ')})" }
        end
        tokens(ctx)
      end

      def enums(mtc, errs)
        errs << "_config.yml: modootoday.twins must be true, false or source (got #{mtc['twins'].inspect})" if mtc.key?("twins") && ![true, false, "source"].include?(mtc["twins"])
        errs << "_config.yml: modootoday.color_scheme must be auto, auto-dark, auto-light, light or dark (got #{mtc['color_scheme'].inspect})" if mtc.key?("color_scheme") && !%w[auto auto-dark auto-light light dark].include?(mtc["color_scheme"])
        errs << "_config.yml: modootoday.csp must be strict or false (got #{mtc['csp'].inspect})" if mtc.key?("csp") && mtc["csp"] != "strict" && mtc["csp"] != false
        errs << "_config.yml: modootoday.languages must be a list of language codes such as [en, ko]" if mtc.key?("languages") && !(mtc["languages"].is_a?(Array) && mtc["languages"].all? { |l| l.to_s =~ /\A[a-z]{2,3}(-[A-Za-z0-9]+)*\z/ })
      end

      # full_languages: the languages that must translate every default-language page (modootoday-check --i18n-pages).
      def full_languages(mtc, errs)
        return unless mtc.key?("full_languages")
        fl, langs = mtc["full_languages"], Array(mtc["languages"]).map(&:to_s)
        return errs << "_config.yml: modootoday.full_languages must be a list of codes from modootoday.languages" unless fl.is_a?(Array)
        (fl.map(&:to_s) - langs).each { |l| errs << "_config.yml: modootoday.full_languages: '#{l}' is not in modootoday.languages" }
      end

      def tokens(ctx)
        mtc, errs = ctx.mtc, ctx.errs
        %w[tokens tokens_dark].each do |k|
          next unless mtc.key?(k)
          next errs << "_config.yml: modootoday.#{k} must be a map" unless mtc[k].is_a?(Hash)
          mtc[k].each do |name, val|
            ctx.warns << "_config.yml: modootoday.#{k}.#{name}: not a semantic token (#{SEMANTIC.join(', ')})" unless SEMANTIC.include?(name.to_s)
            v = val.to_s.strip
            if v.empty? || v =~ /[;{}<>]/ || v !~ /\A[#\w\s.,%()"'+\-*\/]+\z/
              errs << "_config.yml: modootoday.#{k}.#{name}: invalid CSS value #{val.inspect}"
            elsif v.start_with?("#") && v !~ /\A#(\h{3}|\h{4}|\h{6}|\h{8})\z/
              errs << "_config.yml: modootoday.#{k}.#{name}: invalid hex color #{val.inspect}"
            end
          end
        end
      end
    end
  end
end
