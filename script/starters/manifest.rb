# frozen_string_literal: true

require "yaml"

module Starters
  ManifestError = Class.new(StandardError)

  # One starter: its source folder, the repository it is published to, its languages (first = default),
  # the stacks it is rendered for and the modootoday-check flags its sites pass.
  Starter = Struct.new(:name, :dir, :repo, :languages, :stacks, :check, keyword_init: true)

  # example/starters.yml: the one list of starters. Each source folder sits beside the manifest.
  class Manifest
    FIELDS = %w[name repo languages stacks check].freeze
    NAME = /\A[a-z][a-z0-9-]*\z/
    REPO = %r{\A[\w.-]+/[\w.-]+\z}

    attr_reader :path, :starters

    def initialize(path, theme)
      @path, @theme = path, theme
      data = YAML.safe_load(File.read(path))
      list = data.is_a?(Hash) ? data["starters"] : nil
      raise ManifestError, "#{path}: needs a starters: list" unless list.is_a?(Array) && !list.empty?
      @starters = list.map { |e| starter(e) }
      dup = @starters.map(&:name).tally.select { |_, n| n > 1 }.keys
      raise ManifestError, "#{path}: starter #{dup.first} is listed twice" unless dup.empty?
    rescue Psych::Exception => e
      raise ManifestError, "#{path}: #{e.message}"
    end

    def fetch(name) = starters.find { |s| s.name == name } || raise(ManifestError, "#{path}: no starter #{name}")

    private

    def starter(e)
      raise ManifestError, "#{path}: each starter is a map of #{FIELDS.join(", ")}" unless e.is_a?(Hash) && (e.keys - FIELDS).empty?
      name = e["name"].to_s
      raise ManifestError, "#{path}: name #{name.inspect}: lowercase letters, digits and -" unless name.match?(NAME)
      dir = File.join(File.dirname(path), name)
      raise ManifestError, "#{name}: source folder #{dir} has no _config.yml" unless File.file?(File.join(dir, "_config.yml"))
      raise ManifestError, "#{name}: repo: owner/name" unless e["repo"].to_s.match?(REPO)
      Starter.new(name: name, dir: dir, repo: e["repo"], languages: list(e, name, "languages", @theme.languages),
                  stacks: list(e, name, "stacks", @theme.stacks), check: Array(e["check"]).map(&:to_s))
    end

    def list(e, name, key, known)
      v = Array(e[key]).map(&:to_s)
      raise ManifestError, "#{name}: #{key}: name at least one" if v.empty?
      bad = v - known
      raise ManifestError, "#{name}: #{key}: unknown #{bad.join(", ")} (have: #{known.join(" ")})" unless bad.empty?
      v
    end
  end
end
