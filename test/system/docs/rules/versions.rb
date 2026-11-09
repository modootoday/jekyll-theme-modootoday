# frozen_string_literal: true

module DocsRules
  # R5: past theme versions only in Migrate and upgrade and the Changelog; never in a heading.
  module Versions
    ALLOWED = %w[guides/upgrade.md reference/changelog.md].freeze
    HEADING = /^#+ .*(?<![\w.])1\.\d+(?![\w.])/
    MENTION = /\b(?:since|in|from|until|before|after)\s+(?:v|version\s+)?1\.\d+(?:\.\d+)?(?![\w.])|(?<![\w.~@-])1\.\d+(?:\.\d+)?(?= (?:look|release|adds|added|changed))|(?<![\w.])1\.\d+(?:\.\d+)?\s*(?:부터|から|以降)/i

    module_function

    def call(pages)
      out = Hash.new { |h, k| h[k] = [] }
      pages.tree.langs.each do |lang|
        pages.docs(lang).each do |p|
          next if ALLOWED.include?(p.key)
          prose = pages.prose(p)
          prose.each_line.with_index(1) do |l, i|
            out["R5 no version in a heading"] << "#{p.rel}:#{i}: #{l.strip}" if l.match?(HEADING)
            out["R5 no past version in the body"] << "#{p.rel}:#{i}: #{l[MENTION]}" if !l.start_with?("#") && l.match?(MENTION)
          end
        end
      end
      out
    end
  end
end
