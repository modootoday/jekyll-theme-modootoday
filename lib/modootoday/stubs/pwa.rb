# frozen_string_literal: true

module Modootoday
  module Stubs
    # The entry files modootoday.pwa needs at the site root, which a remote theme cannot add, and their one owner. sw.js
    # sits at the baseurl root because a worker's scope is its folder. Never pruned: without sw.js visitors' workers stay
    # forever, so a site that turns the PWA off keeps it, and it renders the self-removing worker.
    class Pwa
      MANIFEST = "manifest.webmanifest"
      WORKER = "sw.js"
      OFFLINE = "offline.md"
      ENABLED = [true, "kill"].freeze
      LANG = /\A[a-z]{2,3}(-[A-Za-z]{2,4})?\z/

      def self.root(name, include) = "---\nlayout: null\npermalink: /#{name}\nsitemap: false\n---\n{% include modootoday/pwa/#{include} %}\n"

      # The offline page of the default language (lang nil) or of a full language, at /<lang>/offline/.
      def self.offline(lang = nil)
        "---\nlayout: pages/offline\n#{"lang: #{lang}\n" if lang}permalink: /#{"#{lang}/" if lang}offline/\nsitemap: false\nsearch: false\ntwin: false\n---\n"
      end

      def self.ours?(text) = text.include?("modootoday/pwa/") || text.match?(%r{^layout: pages/offline$})

      FILES = { MANIFEST => root(MANIFEST, "manifest.json"), WORKER => root(WORKER, "sw.js"), OFFLINE => offline }.freeze

      # dir: as for Twins (script/docs-index keeps the docs site's stubs under one tool-owned directory); each stub then sets
      # path: to where it would sit.
      def initialize(source, dir: nil)
        @s, @dir = source, dir
        cfg = source.modootoday["pwa"]
        raise ConfigError, "--pwa: set modootoday.pwa.enabled: true (or kill) in _config.yml" unless cfg.is_a?(Hash) && ENABLED.include?(cfg["enabled"])
      end

      # A file of the site's own at a stub path is never overwritten.
      def wanted
        files = FILES.merge(languages.to_h { |l| ["offline.#{l}.md", self.class.offline(l)] })
        files = files.to_h { |rel, body| [File.join(@dir, rel), body.sub("permalink:", "path: #{rel}\npermalink:")] } if @dir
        files.each_key do |rel|
          file = @s.path(rel)
          next unless File.exist?(file) && !self.class.ours?(File.read(file))
          raise DataError, "#{rel}: the site's own file is where the PWA stub goes; delete or rename it"
        end
        files
      end

      def orphans = []

      private

      def languages
        Array(@s.modootoday["full_languages"]).map(&:to_s).each do |l|
          raise DataError, "modootoday.full_languages: #{l.inspect} is not a language code" unless l.match?(LANG)
        end
      end
    end
  end
end
