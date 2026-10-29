# frozen_string_literal: true

module Modootoday
  module Check
    # What every rule reads (source and site paths, options, parsed config and data) and the
    # error/warning lists every rule writes to. Loaded once per run.
    class Context
      SKIP = %r{(^|/)(_site|_includes|_layouts|_data|vendor|node_modules)/}

      attr_reader :src, :site, :argv, :errs, :warns, :mds, :comps, :i18n, :site_cfg, :mtc
      attr_accessor :part_uses

      def initialize(src, site, argv)
        @src, @site, @argv = src, site, argv
        @errs, @warns = [], []
        @part_uses = {} # component -> source pages that use it (parts are looked up in their built HTML)
        comps_file = "#{src}/_data/components.yml"
        @comps = File.exist?(comps_file) ? (YAML.safe_load(File.read(comps_file)) || {}) : nil
        @i18n = Dir.glob("#{src}/_data/i18n/*.yml").to_h { |f| [File.basename(f, ".yml"), YAML.safe_load(File.read(f)) || {}] }
        cfg_file = "#{src}/_config.yml"
        @site_cfg = (File.exist?(cfg_file) && ((YAML.safe_load(File.read(cfg_file), permitted_classes: [Date, Time]) rescue nil) || {})) || {}
        @mtc = @site_cfg["modootoday"] || {}
        # directories listed in the site's exclude: are not pages (e.g. a nested example site)
        excl = Array(@site_cfg["exclude"]).map { |e| e.to_s.chomp("/") }.select { |e| File.directory?("#{src}/#{e}") }
        @mds = Dir.glob("#{src}/**/*.md").reject { |f| f.delete_prefix(src) =~ SKIP }.sort
        @mds.reject! { |f| excl.any? { |e| f.start_with?("#{src}/#{e}/") } }
      end

      def option?(name) = argv.include?(name)
      def rel(f) = f.delete_prefix("#{src}/")
      def skipped?(f) = f.delete_prefix(src) =~ SKIP

      # modootoday.twins: source = front-matter-less mode: a page without front matter is rendered by
      # jekyll-optional-front-matter AND copied raw to its own path, which then is its twin.
      def source_mode? = mtc.is_a?(Hash) && mtc["twins"] == "source"

      # The language of a page path ("ko/guide" -> "ko") when that language has an i18n file.
      def lang_of(r) = (r.split("/").first if r.include?("/") && i18n.key?(r.split("/").first))
    end
  end
end
