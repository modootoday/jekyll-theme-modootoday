# frozen_string_literal: true

module Modootoday
  module Stubs
    ConfigError = Class.new(StandardError)
    DataError = Class.new(StandardError)

    # The site source: _config.yml and the Markdown pages Jekyll renders (not under _ or . folders, not excluded).
    class Source
      SKIP_DIRS = %w[vendor node_modules].freeze
      # Written into stub front matter as a plain YAML scalar: no space (": " and " #" end it), quote, query or fragment.
      SAFE_URL = %r{\A/[^\s"'\\#?]*\z}

      attr_reader :root, :config

      def initialize(root)
        @root = root.chomp("/")
        file = "#{@root}/_config.yml"
        raise ConfigError, "#{file}: not found" unless File.file?(file)
        @config = YAML.safe_load(File.read(file), permitted_classes: [Date, Time]) || {}
        raise ConfigError, "#{file}: not a map" unless @config.is_a?(Hash)
      rescue Psych::Exception => e
        raise ConfigError, "#{file}: #{e.message}"
      end

      def modootoday = config["modootoday"].is_a?(Hash) ? config["modootoday"] : {}
      def path(rel) = "#{root}/#{rel}"
      def files(glob) = Dir.glob(glob, base: root).sort.reject { |r| skip?(r) }

      # A page without front matter gets no stub: Jekyll copies it as is (its own twin in twins: source mode).
      def pages
        @pages ||= files("**/*.md").filter_map do |r|
          text = File.read(path(r))
          Page.new(r, front_matter(r, text)) if Markdown.front_matter?(text)
        end
      end

      # Pages as they will be once planned record pages are written and orphan ones deleted, so other kinds plan
      # for them in the same run.
      def overlay(planned, gone)
        drop = planned.keys + gone
        @pages = (pages.reject { |p| drop.include?(p.rel) } + planned.map { |r, text| Page.new(r, front_matter(r, text)) }).sort_by(&:rel)
      end

      # The front matter of a file in SRC, or nil when it has none.
      def front_matter_of(rel)
        text = File.read(path(rel))
        front_matter(rel, text) if Markdown.front_matter?(text)
      end

      def url!(page, url)
        return url if url.match?(SAFE_URL) && !url.split("/").include?("..")
        raise DataError, "#{page.rel}: unsafe permalink #{url.inspect}"
      end

      private

      def skip?(rel)
        dirs = rel.split("/")[0..-2]
        return true if dirs.any? { |d| d.start_with?("_", ".") || SKIP_DIRS.include?(d) }
        excluded.any? { |e| rel == e || rel.start_with?("#{e}/") || File.fnmatch?(e, rel, File::FNM_PATHNAME) }
      end

      def excluded = @excluded ||= Array(config["exclude"]).map { |e| e.to_s.chomp("/") }

      def front_matter(rel, text)
        fm = Markdown.fm(text)
        fm.is_a?(Hash) ? fm : raise(DataError, "#{rel}: front matter is not a map")
      rescue Psych::Exception => e
        raise DataError, "#{rel}: front matter: #{e.message}"
      end
    end
  end
end
