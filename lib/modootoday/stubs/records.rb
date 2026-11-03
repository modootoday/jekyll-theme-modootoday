# frozen_string_literal: true

module Modootoday
  module Stubs
    # Record pages (modootoday.records): one front-matter-only <dir>/<key>.md per record of a _data list. The stub
    # copies the fields head tags read and the record's list index, so the layout finds the record without a scan.
    class Records
      KEY = /\A[a-z0-9][a-z0-9._-]*\z/
      NAME = /\A[A-Za-z0-9_-]+\z/
      FIELDS = %w[data key dir layout permalink title description facts labels body lang].freeze

      def initialize(source, only: nil)
        @s = source
        cfg = source.modootoday["records"]
        raise ConfigError, "--records: declare the record sets in modootoday.records (see the generated pages recipe)" unless cfg.is_a?(Hash) && !cfg.empty?
        unknown = Array(only) - cfg.keys
        raise ConfigError, "--records=#{unknown.first}: no such set in modootoday.records" unless unknown.empty?
        @sets = cfg.select { |name, _| only.nil? || only.include?(name) }.to_h { |name, set| [name, settings(name, set)] }
      end

      # { stub path relative to SRC => content }
      def wanted
        @wanted ||= @sets.each_with_object({}) do |(name, set), out|
          seen = {}
          items(name, set).each_with_index do |rec, i|
            key = key!(name, set, rec, i, seen)
            path = "#{set["dir"]}/#{key}.md"
            guard!(path)
            out[path] = body(name, set, rec, key, i)
          end
        end
      end

      # Stubs of these sets whose record is gone.
      def orphans
        @sets.flat_map do |name, set|
          @s.files("#{set["dir"]}/*.md").select { |r| record_of(r).to_s.start_with?("#{name}/") && !wanted.key?(r) }
        end
      end

      private

      def settings(name, set)
        raise ConfigError, "modootoday.records.#{name}: must be a map of #{FIELDS.join(", ")}" unless name.match?(NAME) && set.is_a?(Hash) && (set.keys - FIELDS).empty?
        s = { "data" => name, "key" => "slug", "dir" => name, "layout" => "detail", "title" => "title", "description" => "description" }.merge(set)
        s["permalink"] ||= "/#{s["dir"]}/:key/"
        raise ConfigError, "modootoday.records.#{name}.data: a file name in _data (letters, digits, - and _)" unless s["data"].to_s.match?(NAME)
        raise ConfigError, "modootoday.records.#{name}.dir: a folder in SRC, not under _ or ." unless s["dir"].to_s.split("/").all? { |d| d.match?(NAME) && !d.start_with?("_") }
        raise ConfigError, "modootoday.records.#{name}.permalink: a site path with :key, like /#{name}/:key/" unless s["permalink"].to_s.include?(":key")
        %w[layout lang].each { |k| raise ConfigError, "modootoday.records.#{name}.#{k}: letters, digits, - and _ only" unless s[k].nil? || s[k].to_s.match?(NAME) }
        s
      end

      def items(name, set)
        file = %w[json yml yaml].map { |ext| "_data/#{set["data"]}.#{ext}" }.find { |f| File.file?(@s.path(f)) }
        raise DataError, "modootoday.records.#{name}: _data/#{set["data"]}.json not found" unless file
        data = load(file)
        data = data["items"] if data.is_a?(Hash) && data["items"].is_a?(Array)
        raise DataError, "#{file}: must be a list of records (or a map with an items list)" unless data.is_a?(Array) && data.all?(Hash)
        data
      end

      def load(file)
        text = File.read(@s.path(file))
        file.end_with?(".json") ? JSON.parse(text) : YAML.safe_load(text, permitted_classes: [Date, Time])
      rescue JSON::ParserError, Psych::Exception => e
        raise DataError, "#{file}: #{e.message.lines.first.strip}"
      end

      def key!(name, set, rec, i, seen)
        key = rec[set["key"]]
        where = "modootoday.records.#{name}: record #{i}"
        raise DataError, "#{where} has no #{set["key"]}" if key.nil? || key.to_s.empty?
        raise DataError, "#{where}: #{set["key"]} #{key.to_s.inspect} must match #{KEY.source}" unless key.is_a?(String) && key.match?(KEY)
        raise DataError, "#{where}: #{set["key"]} #{key} is also record #{seen[key]}" if seen.key?(key)
        raise DataError, "#{where} (#{key}) has no #{set["title"]} for the page title" if rec[set["title"]].to_s.strip.empty?
        seen[key] = i
        key
      end

      # A record stub may replace an older record stub, never a page someone wrote.
      def guard!(path)
        return unless File.exist?(@s.path(path)) && record_of(path).nil?
        raise DataError, "#{path}: a page without record: is already there (rename it or change modootoday.records dir)"
      end

      def record_of(rel) = (@s.front_matter_of(rel) || {})["record"]

      def body(name, set, rec, key, index)
        url = set["permalink"].gsub(":key", key)
        raise DataError, "modootoday.records.#{name}: unsafe permalink #{url.inspect}" unless url.match?(Source::SAFE_URL) && !url.split("/").include?("..")
        fm = ["layout: #{set["layout"]}", "title: #{JSON.generate(rec[set["title"]].to_s)}"]
        desc = rec[set["description"]]
        fm << "description: #{JSON.generate(desc.to_s)}" unless desc.nil? || desc.to_s.empty?
        fm << "lang: #{set["lang"]}" if set["lang"]
        fm += ["permalink: #{url}", "record: #{name}/#{key}", "record_index: #{index}", "twin: false"]
        "---\n#{fm.join("\n")}\n---\n"
      end
    end
  end
end
