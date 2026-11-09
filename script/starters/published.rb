# frozen_string_literal: true

require "open3"
require "fileutils"

module Starters
  # A starter published to its own repository: a gitlink at its path whose work tree holds the rendered github-pages
  # tree. Its content is that tree without the files the renderer owns, and with the remote_theme pin turned back into
  # the theme line, so it renders like a plain folder.
  class Published
    PIN = /^remote_theme: (\S+)@v(\d+\.\d+\.\d+)$/
    REMOTE_PLUGIN = "jekyll-remote-theme"

    # Whether git records rel (relative to root) as a gitlink (mode 160000); false outside a git checkout.
    def self.gitlink?(root, rel)
      out, st = Open3.capture2e("git", "-C", root, "ls-files", "--stage", "--", rel)
      st.success? && out.lines.any? { |l| l.start_with?("160000 ") && l.chomp.end_with?("\t#{rel}") }
    end

    attr_reader :starter

    def initialize(starter, theme)
      @starter, @theme = starter, theme
      @config = File.read(File.join(starter.dir, "_config.yml"))
      m = @config.match(PIN)
      raise ManifestError, "#{starter.name}/_config.yml: a published starter pins remote_theme: #{theme.repo}@vX.Y.Z" unless m && m[1] == theme.repo
      @pin = m[2]
    end

    # The theme release in remote_theme.
    def pin = @pin

    # The content a person writes, as a plain starter folder: written into dir, which is returned.
    def extract(dir, owned)
      FileUtils.rm_rf(dir)
      Render.files(starter.dir).reject { |f| owned.include?(f.split("/").first) }.each do |f|
        FileUtils.mkdir_p(File.dirname(File.join(dir, f)))
        File.binwrite(File.join(dir, f), File.binread(File.join(starter.dir, f)))
      end
      File.binwrite(File.join(dir, "_config.yml"), source_config)
      dir
    end

    private

    # Site#config in reverse: the pin becomes the theme line and the remote theme plugin leaves the list.
    def source_config
      text = @config.sub(PIN, "theme: #{@theme.name}")
      inner = text[/^plugins: \[(.*)\]$/, 1]
      return text unless inner
      rest = inner.split(",").map(&:strip).reject { |p| p.empty? || p == REMOTE_PLUGIN }
      rest.empty? ? text.sub(/^plugins: \[.*\]\n/, "") : text.sub(/^plugins: \[.*\]$/, "plugins: [#{rest.join(", ")}]")
    end
  end
end
