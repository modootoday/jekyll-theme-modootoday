# frozen_string_literal: true

require "yaml"
require "date"

module Starters
  # One starter on one stack, as the templates see it: its _config.yml for that stack and the values
  # README.md, Gemfile and the Pages workflow print.
  class Site
    attr_reader :starter, :stack, :theme

    def initialize(starter, stack, theme)
      @starter, @stack, @theme = starter, stack, theme
      @source = File.read(File.join(starter.dir, "_config.yml"))
      @cfg = YAML.safe_load(@source, permitted_classes: [Date, Time]) || {}
      line = "theme: #{theme.name}"
      raise ManifestError, "#{starter.name}/_config.yml: needs the line #{line}" unless @source.lines.count { |l| l.chomp == line } == 1
      raise ManifestError, "#{starter.name}/_config.yml: exclude: must list README.md" unless Array(@cfg["exclude"]).include?("README.md")
    end

    def remote? = theme.remote?(stack)
    def title = @cfg["title"].to_s
    def description = @cfg["description"].to_s
    def mt = @cfg["modootoday"].is_a?(Hash) ? @cfg["modootoday"] : {}
    # For a bundle: on the classic stack --github-pages also reads the github-pages pin from Gemfile.lock.
    def check_flags = (starter.check + (remote? ? ["--github-pages"] : [])).join(" ")

    # The stub kinds this site's settings ask for; the README tells the reader to run the same command.
    def stub_kinds = [:twins] + (mt["records"] ? [:records] : []) + (mt["aliases"] ? [:aliases] : [])
    def stub_flags = stub_kinds.map { |k| "--#{k}" }.join(" ")

    # The classic stack loads the theme with remote_theme, pinned to this release's tag.
    def config
      return @source unless remote?
      remote = "remote_theme: #{theme.repo}@v#{theme.version}"
      text = @source.sub(/^theme: #{Regexp.escape(theme.name)}$/, remote)
      if (inner = text[/^plugins: \[(.*)\]$/, 1])
        text.sub(/^plugins: \[.*\]$/, "plugins: [#{["jekyll-remote-theme", *inner.split(",").map(&:strip).reject(&:empty?)].join(", ")}]")
      elsif text.match?(/^plugins:/)
        raise ManifestError, "#{starter.name}/_config.yml: write plugins: as a [list] on one line"
      else
        text.sub(/^#{Regexp.escape(remote)}$/, "#{remote}\nplugins: [jekyll-remote-theme]")
      end
    end
  end
end
