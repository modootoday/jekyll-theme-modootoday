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
  # A published starter's github-pages tree is its own work tree (a gitlink); its other trees render from its content.
  class Render
    # Build output, lock files and a submodule's .git file are never part of a starter, in a source or a rendered tree.
    SKIP = %w[_site .jekyll-cache .sass-cache .jekyll-metadata Gemfile.lock .git].freeze
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

    # Every tree of every starter; a published github-pages tree is copied from the work tree as committed.
    def all(out)
      FileUtils.rm_rf(out)
      manifest.starters.each do |s|
        s.stacks.each do |k|
          dir = File.join(out, k, s.name)
          s.published && theme.remote?(k) ? mirror(s.dir, dir) : one(s, k, dir)
        end
      end
      out
    end

    def one(starter, stack, dir, theme: @theme)
      return Dir.mktmpdir { |t| one(content(starter, t), stack, dir, theme: theme) } if starter.published
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

    # Rewrites a published starter's work tree as this checkout renders it, pinned to the gemspec version, for a
    # person to commit in the starter's repository. Returns the paths it wrote or removed.
    def publish(starter)
      raise ManifestError, "#{starter.name}: #{starter.path} is not a gitlink to a published repository" unless starter.published
      Dir.mktmpdir do |t|
        changed = compare(one(starter, "github-pages", File.join(t, starter.name)), starter.dir)
        mirror(File.join(t, starter.name), starter.dir)
        changed
      end
    end

    # Paths that differ between DIR and a fresh render of every starter, and between each published starter and a
    # render of its content at the release it pins (none = no drift).
    def drift(dir)
      fresh = Dir.mktmpdir { |t| compare(all(t), dir) }
      fresh + manifest.starters.select(&:published).flat_map do |s|
        pinned = theme.at(Published.new(s, theme).pin)
        Dir.mktmpdir { |t| compare(one(s, "github-pages", File.join(t, s.name), theme: pinned), s.dir).map { |l| "#{s.path}/#{l}" } }
      end
    end

    # [errors, warnings] about the pins: a published starter pins a released version, and warns when it is behind.
    def pins
      list = manifest.starters.select(&:published).map { |s| [s, Published.new(s, theme).pin] }
      errors = list.reject { |_, v| theme.released.include?(v) }.map { |s, v| "#{s.path}: remote_theme pins v#{v}, which is not a released version" }
      warns = list.select { |_, v| Gem::Version.new(v) < Gem::Version.new(theme.version) }
                  .map { |s, v| "#{s.path}: pins v#{v}, behind #{theme.version} (rake starters:render[#{s.name}])" }
      [errors, warns]
    end

    # Every file under dir, relative and sorted, without build output.
    def self.files(dir)
      Dir.glob("**/*", File::FNM_DOTMATCH, base: dir).reject { |f| f.split("/").any? { |p| SKIP.include?(p) || p == "." } }
         .select { |f| File.file?(File.join(dir, f)) }.sort
    end

    private

    # A published starter as a plain folder of its content under dir.
    def content(starter, dir)
      src = Published.new(starter, theme).extract(File.join(dir, starter.name), OWNED)
      starter.dup.tap { |c| c.dir, c.published = src, false }
    end

    def compare(want_dir, have_dir)
      want, have = self.class.files(want_dir), File.directory?(have_dir) ? self.class.files(have_dir) : []
      (want - have).map { |f| "#{f}: missing" } + (have - want).map { |f| "#{f}: not rendered" } +
        (want & have).reject { |f| File.binread(File.join(want_dir, f)) == File.binread(File.join(have_dir, f)) }.map { |f| "#{f}: differs" }
    end

    # Leaves the folder to with exactly the files of from; what files skips (.git, build output) stays untouched.
    def mirror(from, to)
      (self.class.files(to) - self.class.files(from)).each { |f| File.delete(File.join(to, f)) } if File.directory?(to)
      self.class.files(from).each { |f| copy(File.join(from, f), File.join(to, f)) }
      to
    end

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
