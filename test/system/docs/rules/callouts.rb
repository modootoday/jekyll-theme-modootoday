# frozen_string_literal: true

require "yaml"

module DocsRules
  # Callouts (adr:modootoday/20261109225554): a GitHub alert names one of the types the glossary defines, and a docs
  # page holds at most MAX of them. The Components pages and kitchen sinks show every type and are exempt from MAX.
  module Callouts
    MAX = 3
    MARKER = /^> \[!(\w+)\]/
    SHOWCASE = "components/"

    module_function

    def call(pages)
      out = Hash.new { |h, k| h[k] = [] }
      known = types
      pages.tree.langs.each do |lang|
        pages.docs(lang).each do |p|
          found = pages.body(p).scan(MARKER).flatten
          (found.map(&:upcase).uniq - known).each { |t| out["Callouts: known alert type"] << "#{p.rel}: [!#{t}] is not an alert type (#{known.join(", ")})" }
          next if found.size <= MAX || p.key.start_with?(SHOWCASE)
          out["Callouts: at most three per page"] << "#{p.rel}: #{found.size} callouts (at most #{MAX})"
        end
      end
      out
    end

    # The alert types are the glossary's "<TYPE> alert" terms, each with the line that says when to use it.
    def types
      file = File.expand_path("../../../../i18n/glossary.yml", __dir__)
      YAML.safe_load(File.read(file))["terms"].filter_map { |t| t["en"][/\A([A-Z]+) alert\z/, 1] }
    end
  end
end
