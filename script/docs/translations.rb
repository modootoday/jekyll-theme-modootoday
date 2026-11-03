# frozen_string_literal: true

require_relative "../../lib/modootoday/i18n"
require_relative "../../lib/modootoday/stubs/page"

module DocsIndex
  # The front matter script/docs-index owns in a translation (guides/install.ko.md, feed.ko.xml): lang: and
  # permalink: on every run; source_rev: only when a translator stamps the file after bringing it up to date.
  class Translations
    FIELDS = %w[lang permalink source_rev].freeze

    def initialize(tree)
      @t = tree
      @pl = tree.page_lang
    end

    # { path => content with lang: and permalink: set } for every translation file.
    def files
      @files ||= paths.to_h { |path| [path, set(File.read(path), fields(path))] }
    end

    # { path => content with source_rev: set to its source's revision as well }.
    def stamp(paths)
      paths.to_h do |path|
        rel = path.delete_prefix("#{@t.root}/")
        raise ArgumentError, "#{rel}: not a translation beside its source" unless path.start_with?("#{@t.root}/") && @pl.sibling?(rel)
        src = "#{@t.root}/#{@pl.source(rel)}"
        raise ArgumentError, "#{rel}: no source at #{@pl.source(rel)}" unless File.file?(src)
        rev = Modootoday::I18n::SourceRev.of(File.read(src))
        [path, set(files.fetch(path) { File.read(path) }, fields(path).merge("source_rev" => rev))]
      end
    end

    private

    def paths
      Dir.glob("#{@t.root}/**/*.{md,xml}").reject { |f| f.delete_prefix("#{@t.root}/").start_with?("_", "vendor/", "generated/") }
         .select { |f| @pl.sibling?(f.delete_prefix("#{@t.root}/")) }.sort
    end

    def fields(path)
      rel = path.delete_prefix("#{@t.root}/")
      lang = @pl.of(rel)
      page = @t.pages.find { |p| p.path == path }
      url = page ? page.url : @pl.url("/#{@pl.source(rel)}", lang)
      { "lang" => lang, "permalink" => url }
    end

    # Replaces each field's top-level line, or adds it after the fields before it (at the top when none is there).
    def set(text, values)
      head, sep, body = text.partition(/^---\r?\n/m)
      return set("---\n---\n#{text}", values) unless head.empty? && !sep.empty? && body.match?(/^---\r?\n/)
      fm, close, rest = body.partition(/^---\r?\n/)
      lines = fm.lines
      values.each do |key, value|
        line = "#{key}: #{value}\n"
        at = lines.index { |l| l.start_with?("#{key}:") }
        next lines[at] = line if at
        before = FIELDS[0...FIELDS.index(key)].filter_map { |k| lines.index { |l| l.start_with?("#{k}:") } }.max
        lines.insert(before ? before + 1 : 0, line)
      end
      "#{sep}#{lines.join}#{close}#{rest}"
    end
  end
end
