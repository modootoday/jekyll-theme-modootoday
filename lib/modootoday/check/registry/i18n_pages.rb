# frozen_string_literal: true

require_relative "../../stubs/page"

module Modootoday
  module Check
    # --i18n-pages: translated pages against their default-language source. Warnings (--strict fails): a page with
    # no translation in a modootoday.full_languages language, a translation with no source_rev or a stale one.
    # Error: a sibling translation (x.ko.md) whose permalink is not its source's URL under /<lang>.
    module I18nPages
      # Pages modootoday-stubs writes for each language: nothing to translate, so no source_rev to keep.
      GENERATED = %w[twin pages/offline].freeze

      module_function

      def call(ctx)
        idx = I18n.page_index(ctx)
        missing(ctx, idx)
        idx.each do |r, fm, l|
          next if l == ctx.default_lang || GENERATED.include?(fm["layout"])
          src = source_of(ctx, idx, r, fm)
          translation(ctx, r, fm, l, src) if src
        end
      end

      # Every default-language page has a page in each full language: the one with the same ref:, else its
      # translation (x.ko.md beside it, or ko/x.md).
      def missing(ctx, idx)
        full = Array(ctx.mtc["full_languages"]).map(&:to_s)
        return ctx.warns << "--i18n-pages: set modootoday.full_languages to the languages that translate every page" if full.empty?
        pl = ctx.page_lang
        siblings = idx.any? { |r, _, _| pl.sibling?(r) }
        have = idx.to_h { |r, fm, l| [[l, fm["ref"] ? "ref:#{fm['ref']}" : pl.source(r)], true] }
        idx.each do |r, fm, l|
          next unless l == ctx.default_lang && fm["layout"] != "twin" && !own_page?(r, fm)
          (full - [ctx.default_lang]).each do |fl|
            next if have[[fl, fm["ref"] ? "ref:#{fm['ref']}" : r]]
            where = fm["ref"] ? "ref: #{fm['ref']}" : (siblings ? pl.sibling(r, fl) : "#{fl}/#{r}")
            ctx.warns << "#{r}: no #{fl} page (#{where}); #{fl} is in modootoday.full_languages"
          end
        end
      end

      # Pages that are not translated page by page: a post (each language writes its own posts), a record page or
      # a list of records (made from data) and a page at a file URL such as /404.html (the host serves that file).
      def own_page?(r, fm)
        url = fm["permalink"].to_s
        r.split("/").include?("_posts") || fm.key?("record") || fm.key?("records") || (!url.empty? && !url.end_with?("/"))
      end

      # The default-language page a translation follows: the one with the same ref:, else the file its name
      # or folder points at. Translations without one are reported by I18n.follow_default.
      def source_of(ctx, idx, r, fm)
        if fm["ref"]
          hit = idx.find { |sr, sfm, sl| sl == ctx.default_lang && sfm["ref"] == fm["ref"] && sr != r }
          return hit&.first
        end
        return unless ctx.page_lang.translation?(r)
        src = ctx.page_lang.source(r)
        src if File.file?("#{ctx.src}/#{src}")
      end

      def translation(ctx, r, fm, lang, src)
        text = File.read("#{ctx.src}/#{src}")
        permalink(ctx, r, fm, lang, src, text) if ctx.page_lang.sibling?(r)
        now = Modootoday::I18n::SourceRev.of(text)
        rev = fm["source_rev"]
        if rev.nil?
          ctx.warns << "#{r}: no source_rev; once it matches #{src}, set source_rev: #{now}"
        elsif rev != now
          ctx.warns << "#{r}: stale: source #{src} changed since #{rev} (now #{now})"
        end
      end

      # A file name such as install.ko.md gives Jekyll no usable URL, so the translation states it.
      def permalink(ctx, r, fm, lang, src, text)
        want = ctx.page_lang.url(Stubs::Page.new(src, Markdown.fm(text) || {}).url, lang)
        return if fm["permalink"] == want
        ctx.errs << "#{r}: permalink #{fm['permalink'] || '(none)'} must be #{want}, the URL of #{src} under /#{lang}"
      end
    end
  end
end
