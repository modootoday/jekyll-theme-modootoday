# frozen_string_literal: true

require "erb"
require "fileutils"
require "tmpdir"
require_relative "../../lib/modootoday/stubs"
require_relative "manifest"
require_relative "theme"
require_relative "site"

module Starters
  # Renders each starter for each of its stacks into OUT/<stack>/<name>/: the source folder, then the files the
  # theme owns (Gemfile, README.md, the Pages workflow, the demo overlay, stubs). The same inputs give the same bytes. Interface
  # catalogs are never copied: the theme ships every manifest language, and a copy would freeze its strings.
  class Render
    # Build output and lock files are never part of a starter, in the source or in a rendered tree.
    SKIP = %w[_site .jekyll-cache .sass-cache .jekyll-metadata Gemfile.lock].freeze
    # Written only by the renderer, so a source folder must not have them.
    OWNED = %w[Gemfile README.md .github _config.demo.yml].freeze
    # Rendered path => template under templates/ (.erb).
    RENDERED = { "Gemfile" => "Gemfile", "README.md" => "README.md", "_config.demo.yml" => "config.demo.yml",
                 ".github/workflows/pages.yml" => "pages.yml" }.freeze
    TEMPLATES = File.join(__dir__, "templates")

    attr_reader :manifest, :theme

    def initialize(manifest, theme)
      @manifest, @theme = manifest, theme
    end

    def all(out)
      FileUtils.rm_rf(out)
      manifest.starters.each { |s| s.stacks.each { |k| one(s, k, File.join(out, k, s.name)) } }
      out
    end

    def one(starter, stack, dir)
      site = Site.new(starter, stack, theme)
      owned = OWNED.select { |f| File.exist?(File.join(starter.dir, f)) }
      raise ManifestError, "#{starter.name}: #{owned.join(", ")} are rendered; remove them from #{starter.dir}" unless owned.empty?
      FileUtils.rm_rf(dir)
      self.class.files(starter.dir).each { |f| copy(File.join(starter.dir, f), File.join(dir, f)) }
      write(dir, "_config.yml", site.config)
      RENDERED.each do |path, t|
        write(dir, path, ERB.new(File.read(File.join(TEMPLATES, "#{t}.erb")), trim_mode: "-").result(site.instance_eval { binding }))
      end
      source = Modootoday::Stubs::Source.new(dir)
      Modootoday::Stubs::Writer.apply(source, Modootoday::Stubs::Plan.new(source, site.stub_kinds).changes)
      dir
    end

    # Paths that differ between DIR and a fresh render of every starter (none = no drift).
    def drift(dir)
      Dir.mktmpdir do |t|
        want, have = self.class.files(all(t)), File.directory?(dir) ? self.class.files(dir) : []
        (want - have).map { |f| "#{f}: missing" } + (have - want).map { |f| "#{f}: not rendered" } +
          (want & have).reject { |f| File.binread(File.join(t, f)) == File.binread(File.join(dir, f)) }.map { |f| "#{f}: differs" }
      end
    end

    # Every file under dir, relative and sorted, without build output.
    def self.files(dir)
      Dir.glob("**/*", File::FNM_DOTMATCH, base: dir).reject { |f| f.split("/").any? { |p| SKIP.include?(p) || p == "." } }
         .select { |f| File.file?(File.join(dir, f)) }.sort
    end

    private

    def copy(from, to)
      FileUtils.mkdir_p(File.dirname(to))
      File.binwrite(to, File.binread(from))
    end

    def write(dir, path, text)
      FileUtils.mkdir_p(File.dirname(File.join(dir, path)))
      File.binwrite(File.join(dir, path), text)
    end
  end
end
