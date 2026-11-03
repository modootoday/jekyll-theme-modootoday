# frozen_string_literal: true

module Modootoday
  module Stubs
    # Twin stubs (RULES.md 5a): <name>.md.txt next to each page, rendered by the twin layout at /<page>/index.md.
    # script/docs-index uses this class too, with dir: so the docs site keeps its stubs under one tool-owned directory;
    # there each stub sets path: to where it would sit, so the twin layout still resolves its page.
    class Twins
      def initialize(source, dir: nil)
        @s = source
        @dir = dir
      end

      def pages = @s.pages.reject { |p| p.name == "README.md" || p.fm["twin"] == false }

      # { stub path relative to SRC => content }
      def wanted
        pages.to_h do |p|
          rel = "#{p.rel}.txt"
          path = @dir ? "#{lang(rel)}path: #{rel}\n" : ""
          [File.join(*[@dir, rel].compact), "---\nlayout: twin\ntwin_of: #{p.name}\n#{path}permalink: #{@s.url!(p, p.url)}index.md\n---\n"]
        end
      end

      # Twin stubs whose page is gone (alias stubs belong to Aliases).
      def orphans
        base = @dir ? "#{@dir}/" : ""
        @s.files("#{base}**/*.md.txt").reject { |r| Aliases.stub?(r) || File.exist?(@s.path(r.delete_prefix(base).delete_suffix(".txt"))) }
      end

      private

      # A defaults scope matches the stub's real path, so a moved stub carries the lang its old place gave it.
      def lang(rel)
        value = @s.default(rel, "lang")
        value ? "lang: #{value}\n" : ""
      end
    end
  end
end
