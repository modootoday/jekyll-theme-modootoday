# frozen_string_literal: true

require "fileutils"
require "json"

module Bench
  # A synthetic site for the records benchmark: N records in _data/skills.json, one stub page each (written by
  # modootoday-stubs), a directory page that lists them and the theme copied in, as a classic Pages build sees it.
  module Fixture
    ROOT = File.expand_path("../..", __dir__)
    THEME = %w[_layouts _includes _sass assets].freeze
    WORDS = %w[page record search filter theme build layout render static index token module list table guide].freeze
    CONFIG = <<~YAML
      title: Records benchmark
      lang: en
      permalink: pretty
      markdown: kramdown
      kramdown: {input: GFM, syntax_highlighter: rouge}
      time: 2026-11-02T00:00:00+00:00
      modootoday:
        records:
          skills: {title: name, description: summary, facts: [category, version, tags], body: readme}
    YAML

    module_function

    # where: true drops record_index from the stubs, so every page falls back to the where scan (the comparison run).
    def write(dir, count, where: false)
      FileUtils.rm_rf(dir)
      FileUtils.mkdir_p("#{dir}/_data")
      THEME.each { |d| FileUtils.cp_r("#{ROOT}/#{d}", "#{dir}/#{d}") }
      File.write("#{dir}/_config.yml", CONFIG)
      File.write("#{dir}/_data/skills.json", JSON.pretty_generate(Array.new(count) { |i| record(i) }))
      File.write("#{dir}/index.md", "---\ntitle: Home\n---\n# Records benchmark\n\n[All skills](skills/)\n")
      File.write("#{dir}/skills.md", "---\ntitle: Skills\nlayout: integrations\nrecords: skills\nfilter_text: true\n---\n# Skills\n")
      stubs = system(RbConfig.ruby, "#{ROOT}/exe/modootoday-stubs", dir, "--records", "--write", "--quiet")
      raise "modootoday-stubs failed" unless stubs
      drop_index(dir) if where
      dir
    end

    # Deterministic records of a realistic size: about 300 words of Markdown each.
    def record(i)
      slug = format("skill-%04d", i)
      words = Array.new(300) { |w| WORDS[(i * 7 + w * 3) % WORDS.size] }
      paras = words.each_slice(60).map { |s| s.join(" ").capitalize + "." }
      { "slug" => slug, "name" => "Skill #{i}", "summary" => "Synthetic record #{i} for the build benchmark.",
        "category" => %w[Reading Publishing Feeds Search][i % 4], "version" => "1.#{i % 10}.0",
        "tags" => [WORDS[i % WORDS.size], WORDS[(i + 5) % WORDS.size]],
        "readme" => "#{paras[0]}\n\n## Use\n\n#{paras[1..].join("\n\n")}\n\n- one\n- two\n" }
    end

    def drop_index(dir)
      Dir.glob("#{dir}/skills/*.md").each { |f| File.write(f, File.read(f).sub(/^record_index: \d+\n/, "")) }
    end
  end
end
