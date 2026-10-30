# frozen_string_literal: true

require "fileutils"

module Modootoday
  module Check
    # Interface catalogs: site _data/i18n/<lang>.yml against the default language and the theme's
    # built-in catalogs (i18n/<code>.yml in the gem), --i18n-init and --i18n.
    module I18n
      THEME = File.expand_path("../../../i18n", __dir__)

      module_function

      def leaves(h, pre = nil) = h.is_a?(Hash) ? h.flat_map { |k, v| leaves(v, [pre, k].compact.join(".")) } : [[pre, h]]
      def keys(h) = leaves(h).map(&:first)
      def theme_codes = Dir.glob("#{THEME}/*.yml").map { |f| File.basename(f, ".yml") } - %w[languages glossary]

      # Keys the theme ships for a language (exact code, else its base subtag; never ur -> ur-Latn).
      def theme_keys(lang)
        f = "#{THEME}/#{lang}.yml"
        f = Dir.glob("#{THEME}/#{lang.split('-').first}-*.yml").reject { |x| x.end_with?("/ur-Latn.yml") }.min unless File.file?(f)
        f ? keys(YAML.safe_load(File.read(f))) : []
      end

      def base_lang(ctx)
        b = ctx.site_cfg["lang"].to_s.split("-").first
        b.to_s.empty? ? "en" : b
      end

      def call(ctx)
        Dir.glob("#{ctx.src}/_data/i18n/*.yaml").each { |f| ctx.errs << "#{ctx.rel(f)}: catalogs use .yml; rename to #{File.basename(f, '.yaml')}.yml" }
        init(ctx) if ctx.argv.any? { |a| a.start_with?("--i18n-init") }
        follow_default(ctx)
        registry(ctx) if ctx.option?("--i18n") && File.exist?("#{THEME}/en.yml")
      end

      def init(ctx)
        ini = ctx.argv.find { |a| a.start_with?("--i18n-init") }
        want = ini.split("=", 2)[1].to_s.split(",").map(&:strip).reject(&:empty?)
        want = theme_codes if want.empty? || want == ["all"]
        FileUtils.mkdir_p("#{ctx.src}/_data/i18n")
        want.each do |l|
          from, to = "#{THEME}/#{l}.yml", "#{ctx.src}/_data/i18n/#{l}.yml"
          next ctx.errs << "--i18n-init: no starter catalog for '#{l}' (have: #{theme_codes.sort.join(' ')})" unless File.exist?(from)
          next (FileUtils.cp(from, to); puts "created #{to}") unless File.exist?(to)
          ref = YAML.safe_load(File.read(from))
          (keys(ref) - keys(YAML.safe_load(File.read(to)) || {})).each { |k| puts "#{to}: missing #{k}: #{k.split('.').reduce(ref) { |a, x| a[x] }.inspect}" }
        end
      end

      # Translations follow the default language: a translated key must exist in the default file or the
      # theme registry; a key the default file has that a translation lacks (and the theme does not ship
      # for that language) is a warning; a page under <lang>/ needs a default-language page.
      def follow_default(ctx)
        bl = base_lang(ctx)
        return unless (base = ctx.i18n[bl])

        base_keys = keys(base) | theme_keys("en")
        ctx.i18n.each do |lang, h|
          next if lang == bl

          (keys(h) - base_keys).each { |k| ctx.errs << "_data/i18n/#{lang}.yml: key '#{k}' is not in _data/i18n/#{bl}.yml (#{bl} is canonical; add it there first)" }
          (keys(base) - keys(h) - theme_keys(lang)).each { |k| ctx.warns << "_data/i18n/#{lang}.yml: missing key '#{k}' (falls back to #{bl})" }
          ctx.mds.each do |f|
            r = ctx.rel(f)
            next unless r.start_with?("#{lang}/")

            en = r.delete_prefix("#{lang}/")
            ctx.warns << "#{r}: no #{bl} page at #{en} (translations follow the canonical page)" unless File.exist?("#{ctx.src}/#{en}")
          end
        end
      end

      def registry(ctx)
        reg = leaves(YAML.safe_load(File.read("#{THEME}/en.yml"))).to_h
        site_en = leaves(ctx.i18n[base_lang(ctx)] || {}).to_h
        ph = ->(v) { v.to_s.scan(/%\{(\w+)\}/).flatten.sort }
        ctx.i18n.each do |lang, h|
          leaves(h).each do |k, v|
            next if %w[title description].include?(k) # site-level strings, not theme keys

            next ctx.errs << "_data/i18n/#{lang}.yml: unknown key '#{k}' (not in the theme registry or #{base_lang(ctx)}.yml)" unless reg.key?(k) || site_en.key?(k)

            ref = reg.key?(k) ? reg[k] : site_en[k]
            ctx.errs << "_data/i18n/#{lang}.yml: '#{k}' placeholders #{ph[v].inspect} differ from English #{ph[ref].inspect}" unless ph[v] == ph[ref]
          end
        end
        ctx.mds.each { |f| ctx.warns << "#{ctx.rel(f)}: translation: pending (served as the labeled English fallback)" if (Markdown.fm(File.read(f)) rescue {})["translation"] == "pending" }
      end
    end
  end
end
