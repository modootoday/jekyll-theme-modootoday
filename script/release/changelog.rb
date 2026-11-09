# frozen_string_literal: true

require "open3"

module Release
  class Error < StandardError; end

  # CHANGELOG.md sections rendered by git-cliff from the commits and cliff.toml (adr:modootoday/20261109225758).
  # Only [Unreleased] and a new version's entry are written; a released entry is never regenerated.
  class Changelog
    ROOT = File.expand_path("../..", __dir__)
    FILE = File.join(ROOT, "CHANGELOG.md")
    EMPTY = "## [Unreleased]\n\n"
    PLACEHOLDER = "<!-- release-prep:" # cliff.toml writes it where the release text is hand-written
    SECTION = /^## \[Unreleased\]\n.*?(?=^## \[|^\[[^\]]+\]: https?:|\z)/m

    # git-cliff from npm ci (package.json pins it), else one on PATH; nil when neither is there.
    def self.cliff
      local = File.join(ROOT, "node_modules/.bin/git-cliff")
      return local if File.executable?(local)

      ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).map { |d| File.join(d, "git-cliff") }.find { |f| File.executable?(f) }
    end

    def self.repo_url = File.read(File.join(ROOT, "jekyll-theme-modootoday.gemspec"))[/spec\.homepage\s*=\s*"([^"]+)"/, 1]

    attr_reader :text

    def initialize(text = File.read(FILE)) = @text = text

    # The section of the commits since the last release tag; with tag:, headed and dated as that release.
    def render(tag: nil)
      bin = self.class.cliff or raise Error, "git-cliff is not installed: run npm ci"
      args = [bin, "--config", File.join(ROOT, "cliff.toml"), "--workdir", ROOT, "--unreleased"]
      args += ["--tag", tag] if tag
      out, err, st = Open3.capture3(*args)
      raise Error, "git-cliff failed: #{err.lines.last}" unless st.success?

      "#{out.strip}\n\n"
    end

    def unreleased = text[SECTION]
    def newest = text[/^## \[(\d+\.\d+\.\d+)\]/, 1]

    # After release-prep and before the tag, the commits belong to the prepared entry, so [Unreleased] stays empty.
    def expected_unreleased = prepared? ? EMPTY : render

    def prepared?
      tags = git("tag", "--list", "v*").split
      raise Error, "no release tags in this clone: git fetch --tags (CI: fetch-depth: 0)" if tags.empty?

      !tags.include?("v#{newest}")
    end

    def with_unreleased(section) = text.sub(SECTION) { section }

    # The text with an empty [Unreleased], the entry of version under it and the link definitions moved on.
    def release(version, entry)
      repo = self.class.repo_url
      out = text.sub(SECTION) { EMPTY + entry }
      out.sub(%r{^\[Unreleased\]: \S+$}) { "[Unreleased]: #{repo}/compare/v#{version}...HEAD\n[#{version}]: #{repo}/releases/tag/v#{version}" }
    end

    private

    def git(*args) = Open3.capture2("git", "-C", ROOT, *args).first
  end
end
