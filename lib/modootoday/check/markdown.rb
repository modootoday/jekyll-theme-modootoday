# frozen_string_literal: true

module Modootoday
  module Check
    # Markdown text helpers shared by the rules: front matter, fenced code, code spans, comments.
    module Markdown
      FM = /\A---\r?\n(.*?\r?\n)?---\r?\n/m
      FENCE_OPEN = /^( {0,3})(`{3,}|~{3,})(.*)$/

      module_function

      def fm(t) = (m = t[FM]) ? (YAML.safe_load(m.sub(/\A---\r?\n/, "").sub(/---\r?\n\z/, ""), permitted_classes: [Date, Time]) || {}) : {}
      def body(t) = t.sub(FM, "")

      # Blank out fenced code (CommonMark: closing fence = same char, length >= opener), keep line count.
      # Yields [line_no, info_string] for every opening fence.
      def strip_fences(t)
        out = []
        close = nil
        t.each_line.with_index(1) do |l, n|
          if close
            close = nil if l =~ /^ {0,3}#{Regexp.escape(close[0])}{#{close.size},}\s*$/
            out << "\n"
          elsif (m = l.match(FENCE_OPEN)) && !(m[2].start_with?("`") && m[3].include?("`"))
            close = m[2]
            yield n, m[3].strip if block_given?
            out << "\n"
          else
            out << l
          end
        end
        out.join
      end

      def strip_code(t) = strip_fences(t).gsub(/(`+)(?!`).+?(?<!`)\1(?!`)/) { "``" }
      def strip_comments(t) = t.gsub(/<!--.*?-->/m) { |m| "\n" * m.count("\n") }
    end
  end
end
