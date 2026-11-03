# frozen_string_literal: true

module Modootoday
  module Stubs
    # Twin stubs (RULES.md 5a): <name>.md.txt next to each page, rendered by the twin layout at /<page>/index.md.
    # script/docs-index uses this class too, so the docs site and user sites get the same stubs.
    class Twins
      def initialize(source)
        @s = source
      end

      def pages = @s.pages.reject { |p| p.name == "README.md" || p.fm["twin"] == false }

      # { stub path relative to SRC => content }
      def wanted
        pages.to_h do |p|
          ["#{p.rel}.txt", "---\nlayout: twin\ntwin_of: #{p.name}\npermalink: #{@s.url!(p, p.url)}index.md\n---\n"]
        end
      end

      # Twin stubs whose page is gone (alias stubs belong to Aliases).
      def orphans
        @s.files("**/*.md.txt").reject { |r| Aliases.stub?(r) || File.exist?(@s.path(r.delete_suffix(".txt"))) }
      end
    end
  end
end
