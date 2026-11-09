# frozen_string_literal: true

require "yaml"
require "open3"
require "rbconfig"
require "rubygems"

module Starters
  # What a starter takes from the theme, each read from its one owner: the gemspec (version, repository), CHANGELOG.md
  # (released versions), gemfiles/<stack>.gemfile (gem lines), i18n/languages.yml (languages) and the executables (command tables).
  class Theme
    # remote: the stack loads the theme with remote_theme (classic GitHub Pages) instead of the gem.
    STACKS = { "github-pages" => { remote: true }, "jekyll4" => { remote: false } }.freeze
    # Gems the theme's own test suite needs; a site does not.
    DEV_GEMS = %w[minitest rake].freeze
    EXECUTABLES = { "check" => "exe/modootoday-check", "stubs" => "exe/modootoday-stubs" }.freeze

    # A released version is a dated CHANGELOG heading: ## [X.Y.Z] - YYYY-MM-DD.
    RELEASED = /^## \[(\d+\.\d+\.\d+)\] - \d{4}-\d{2}-\d{2}$/

    attr_reader :root

    # version: the release a published starter pins, when it is rendered as it was published.
    def initialize(root, version = nil)
      @root, @version = root, version
    end

    def gemspec = @gemspec ||= Gem::Specification.load(File.join(root, "jekyll-theme-modootoday.gemspec"))
    def name = gemspec.name
    def version = @version || gemspec.version.to_s
    def at(version) = self.class.new(root, version)
    def released = @released ||= File.read(File.join(root, "CHANGELOG.md")).scan(RELEASED).flatten
    def repo = gemspec.homepage.delete_prefix("https://github.com/")
    def stacks = STACKS.keys.select { |s| File.file?(gemfile(s)) }
    def remote?(stack) = STACKS.fetch(stack)[:remote]
    def languages = @languages ||= YAML.safe_load(File.read(File.join(root, "i18n/languages.yml"))).map { |l| l["code"] }
    def gemfile(stack) = File.join(root, "gemfiles", "#{stack}.gemfile")

    # The gem lines of a stack's bundle, minus the theme's own test tools.
    def gem_lines(stack)
      File.readlines(gemfile(stack), chomp: true).grep(/\Agem "/).reject { |l| DEV_GEMS.include?(l[/\Agem "([^"]+)"/, 1]) }
    end

    # The Markdown option table of each executable (--help=markdown), as the theme README shows it.
    def commands
      @commands ||= EXECUTABLES.transform_values do |exe|
        out, st = Open3.capture2(RbConfig.ruby, File.join(root, exe), "--help=markdown")
        raise "#{exe} --help=markdown failed" unless st.success?
        out
      end
    end
  end
end
