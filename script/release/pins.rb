# frozen_string_literal: true

module Release
  # The version and the install pins that name it: the gemspec, and the install snippets of the READMEs and docs pages.
  # test/project/version_test.rb checks them; script/release-prep rewrites them.
  module Pins
    ROOT = File.expand_path("../..", __dir__)
    GEMSPEC = "jekyll-theme-modootoday.gemspec"
    FILES = %w[README.md README.ko.md README.ja.md docs/guides/install.md docs/guides/install.ko.md docs/guides/install.ja.md
               docs/index.md docs/index.ko.md docs/index.ja.md].freeze
    # label => [pattern with the pinned value in group 2, :minor (X.Y) or :version (X.Y.Z)]
    PATTERNS = {
      "gem constraint" => [/(jekyll-theme-modootoday", "~> )([\d.]+)(")/, :minor],
      "remote_theme tag" => [/(jekyll-theme-modootoday@v)([\d.]+)()/, :version],
      "gem install constraint" => [/(jekyll-theme-modootoday -v '~> )([\d.]+)(')/, :minor],
      "source tarball" => [%r{(tags/v)([\d.]+)(\.tar\.gz)}, :version],
      "source directory" => [%r{(jekyll-theme-modootoday-)(\d[\d.]*)(/exe)}, :version],
    }.freeze

    module_function

    def version = File.read(File.join(ROOT, GEMSPEC))[/spec\.version\s*=\s*"([^"]+)"/, 1]
    def minor(version) = version.split(".")[0, 2].join(".")
    def want(kind, version) = kind == :minor ? minor(version) : version

    # [label, found] for each pin in text that does not name version.
    def mismatches(text, version)
      PATTERNS.flat_map do |label, (re, kind)|
        text.scan(re).map { |m| m[1] }.reject { |v| v == want(kind, version) }.map { |v| [label, v] }
      end
    end

    def rewrite(text, version)
      PATTERNS.values.reduce(text) { |t, (re, kind)| t.gsub(re) { "#{$1}#{want(kind, version)}#{$3}" } }
    end

    # Writes version into the gemspec and every pin; returns the files it changed.
    def bump(version)
      files = { GEMSPEC => ->(t) { t.sub(/(spec\.version\s*=\s*")[^"]+(")/) { "#{$1}#{version}#{$2}" } } }
      FILES.each { |f| files[f] = ->(t) { rewrite(t, version) } }
      files.filter_map do |f, change|
        path = File.join(ROOT, f)
        before = File.read(path)
        after = change.call(before)
        next if after == before

        File.write(path, after)
        f
      end
    end
  end
end
