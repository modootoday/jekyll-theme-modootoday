# frozen_string_literal: true

require "yaml"

module Starters
  ManifestError = Class.new(StandardError)

  # One starter: its source folder, the repository it is published to, the one-line description that repository
  # shows, its languages (first = default), the stacks it is rendered for, the modootoday-check flags its sites pass,
  # its demo's showcase style, the pages its QA opens and the theme documentation the showcase links to.
  Starter = Struct.new(:name, :dir, :repo, :description, :languages, :stacks, :check, :style, :qa, :docs_url, keyword_init: true) do
    # The repository's own Pages site is the live demo; "Use this starter" is GitHub's template link.
    def demo_url = "https://#{repo.split("/").first.downcase}.github.io/#{repo.split("/").last}/"
    def generate_url = "https://github.com/#{repo}/generate"
    def baseurl = "/#{repo.split("/").last}"
    def topics = ["jekyll", "jekyll-theme", "github-pages", "starter-template", name]
  end

  # example/starters.yml: the one list of starters. Each source folder sits beside the manifest.
  class Manifest
    FIELDS = %w[name repo description languages stacks check showcase qa].freeze
    NAME = /\A[a-z][a-z0-9-]*\z/
    REPO = %r{\A[\w.-]+/[\w.-]+\z}
    HTTPS = %r{\Ahttps://\S+/\z}
    STYLES = %w[bar pill].freeze
    # A page path as the built site serves it: empty for the home page, else ending in / or a file name.
    PAGE = %r{\A(?:[\w.-]+/)*(?:[\w.-]+\.\w+)?\z}

    attr_reader :path, :starters, :docs_url

    def initialize(path, theme)
      @path, @theme = path, theme
      data = YAML.safe_load(File.read(path))
      list = data.is_a?(Hash) ? data["starters"] : nil
      raise ManifestError, "#{path}: needs a starters: list" unless list.is_a?(Array) && !list.empty?
      @docs_url = data["demo"].is_a?(Hash) ? data["demo"]["docs_url"].to_s : ""
      raise ManifestError, "#{path}: demo: {docs_url:} is the theme documentation's https:// address, ending in /" unless @docs_url.match?(HTTPS)
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
      Starter.new(name: name, dir: dir, repo: e["repo"], description: description(e, name),
                  languages: list(e, name, "languages", @theme.languages), stacks: list(e, name, "stacks", @theme.stacks),
                  check: Array(e["check"]).map(&:to_s), style: style(e, name), qa: qa(e, name), docs_url: docs_url)
    end

    # GitHub shows it as the repository description: one line, at most 350 characters.
    def description(e, name)
      d = e["description"]
      raise ManifestError, "#{name}: description: one line of text for the repository" unless d.is_a?(String) && d.match?(/\A[^\n]{1,350}\z/)
      d
    end

    def style(e, name)
      v = e["showcase"].nil? ? {} : e["showcase"]
      raise ManifestError, "#{name}: showcase: a map with style: #{STYLES.join(" or ")}" unless v.is_a?(Hash) && (v.keys - ["style"]).empty?
      s = (v["style"] || STYLES.first).to_s
      raise ManifestError, "#{name}: showcase.style: #{STYLES.join(" or ")}" unless STYLES.include?(s)
      s
    end

    def qa(e, name)
      v = Array(e["qa"]).map(&:to_s)
      raise ManifestError, "#{name}: qa: name at least two pages of the demo build" if v.size < 2
      bad = v.reject { |p| p.match?(PAGE) }
      raise ManifestError, "#{name}: qa: #{bad.join(", ")}: a page path without a leading /" unless bad.empty?
      v
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
