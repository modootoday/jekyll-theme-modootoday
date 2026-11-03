# frozen_string_literal: true

module Modootoday
  module I18n
    # Which language a source file is in, which default-language file it translates and the URL it gets.
    # Sibling mode: guides/install.ko.md, and home/index.vi.md for a language that translates only the home page.
    # Directory mode: ko/guides/install.md. The one owner for modootoday-check, script/docs-index and the QA.
    class PageLang
      HOME = "home"

      attr_reader :langs, :default

      def initialize(langs, default)
        @default = default.to_s.empty? ? "en" : default.to_s
        @langs = langs.map(&:to_s) - [@default]
      end

      # Front matter lang: wins, then a .<lang> suffix before the extension, then a <lang>/ folder.
      def of(rel, fm = {})
        given = fm.is_a?(Hash) ? fm["lang"] : nil
        (given || suffix(rel) || folder(rel) || default).to_s
      end

      def suffix(rel)
        parts = File.basename(rel).split(".")
        parts[-2] if parts.size > 2 && langs.include?(parts[-2])
      end

      def folder(rel)
        dir = rel.split("/").first
        dir if rel.include?("/") && langs.include?(dir)
      end

      def sibling?(rel) = !suffix(rel).nil?
      def translation?(rel) = sibling?(rel) || !folder(rel).nil?

      # The default-language file that rel translates; rel itself when it is not a translation.
      def source(rel)
        if (lang = suffix(rel))
          base = rel.sub(/\.#{Regexp.escape(lang)}(\.[^.\/]+)\z/, '\1')
          base.delete_prefix("#{HOME}/")
        elsif (lang = folder(rel))
          rel.delete_prefix("#{lang}/")
        else
          rel
        end
      end

      # Where the lang translation of a default-language file sits in sibling mode.
      def sibling(rel, lang) = rel.sub(/(\.[^.\/]+)\z/, ".#{lang}\\1")

      # A sibling translation keeps the URL its source has, under /<lang>.
      def url(source_url, lang) = lang == default ? source_url : "/#{lang}#{source_url}"
    end
  end
end
