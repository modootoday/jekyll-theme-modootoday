# frozen_string_literal: true

module Modootoday
  module Stubs
    # The entry files modootoday.pwa needs at the site root, which a remote theme cannot add: manifest.webmanifest renders
    # the theme's manifest include. The one owner of their names and contents (modootoday-check reads them here). They are
    # never pruned: a site that turns the PWA off keeps them until it deletes them.
    class Pwa
      MANIFEST = "manifest.webmanifest"
      FILES = { MANIFEST => "---\nlayout: null\npermalink: /#{MANIFEST}\nsitemap: false\n---\n{% include modootoday/pwa/manifest.json %}\n" }.freeze

      def initialize(source)
        @s = source
        cfg = source.modootoday["pwa"]
        raise ConfigError, "--pwa: set modootoday.pwa.enabled: true in _config.yml" unless cfg.is_a?(Hash) && cfg["enabled"] == true
      end

      # A file of the site's own at a stub path is never overwritten.
      def wanted
        FILES.each_key do |rel|
          file = @s.path(rel)
          next unless File.exist?(file) && !File.read(file).include?("modootoday/pwa/")
          raise DataError, "#{rel}: the site's own file is where the PWA stub goes; delete or rename it"
        end
        FILES.dup
      end

      def orphans = []
    end
  end
end
