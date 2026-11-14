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
        # files and folders listed in the site's exclude: are not pages (a repository README.md, a nested site)
        excl = Array(@site_cfg["exclude"]).map { |e| e.to_s.chomp("/") }
        @mds = Dir.glob("#{src}/**/*.md").reject { |f| f.delete_prefix(src) =~ SKIP || unread?(f) }.sort
        @mds.reject! { |f| excl.any? { |e| rel(f) == e || rel(f).start_with?("#{e}/") } }
      end

      def option?(name) = argv.include?(name)
      def rel(f) = f.delete_prefix("#{src}/")
      def skipped?(f) = f.delete_prefix(src) =~ SKIP

      # Files Jekyll does not read as pages: the SITE folder, and folders starting with _ (other builds such as
      # _site_ko) other than _posts, _drafts and the collections.
      def unread?(f)
        @site_dir ||= site ? File.join(File.expand_path(site), "") : "\0"
        return true if File.expand_path(f).start_with?(@site_dir)
        @read_dirs ||= %w[_posts _drafts] + Array(site_cfg["collections"]).map { |c| "_#{c.is_a?(Array) ? c.first : c}" } +
                       Array(site_cfg["include"]).map { |i| i.to_s.chomp("/") }
        rel(f).split("/")[0..-2].any? { |d| d.start_with?("_") && !@read_dirs.include?(d) }
      end

      # modootoday.twins: source = front-matter-less mode: a page without front matter is rendered by
      # jekyll-optional-front-matter AND copied raw to its own path, which then is its twin.
      def source_mode? = mtc.is_a?(Hash) && mtc["twins"] == "source"

      def default_lang = site_cfg["lang"].to_s.empty? ? "en" : site_cfg["lang"].to_s
      def page_lang = @page_lang ||= Modootoday::I18n::PageLang.new(Array(mtc["languages"]) | i18n.keys, default_lang)

      # A page's language, "" for the default one: front matter, the .<lang>.md suffix or the <lang>/ folder.
      def lang_of(rel, fm = {})
        lang = page_lang.of(rel, fm)
        lang == default_lang ? "" : lang
      end
    end
  end
end
