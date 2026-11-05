# frozen_string_literal: true

require "digest"

module Modootoday
  # Static figures: the fences and math blocks a page replaces with committed renders, and the one digest rule that
  # ties a render to its source (data-mt-src on an SVG root, src: in _data/math). Other tools must follow digest exactly.
  module Figures
    FENCE_OPEN = /\A {0,3}(`{3,}|~{3,})\s*(\S*)/
    SRC_ATTR = /\A\s*(?:<\?xml[^>]*>\s*)?(?:<!--.*?-->\s*)*<svg\b[^>]*?\sdata-mt-src="([^"]*)"/m
    VIEWBOX = /\A\s*(?:<\?xml[^>]*>\s*)?(?:<!--.*?-->\s*)*<svg\b[^>]*?\sviewBox="\s*[-\d.]+[\s,]+[-\d.]+[\s,]+([\d.]+)[\s,]+([\d.]+)\s*"/m

    module_function

    # "sha256-<hex>" of the fence body with CRLF and CR as LF and trailing newlines removed.
    def digest(body) = "sha256-#{Digest::SHA256.hexdigest(body.gsub(/\r\n?/, "\n").sub(/\n+\z/, ''))}"

    # Fences of one language in a Markdown body, in order: [{line:, body:}] (line of the opening fence, 1-based).
    def fences(text, lang)
      out = []
      cur = nil
      text.each_line.with_index(1) do |l, n|
        if cur
          if closes?(cur, l)
            out << { line: cur[:line], body: cur[:lines].join } if cur[:lang] == lang
            cur = nil
          else
            cur[:lines] << l
          end
        elsif (cur = opens(l, n))
          cur
        end
      end
      out
    end

    # ```math fences and $$ blocks in document order: [{line:, last:, body:}]. A $$ block's body is the text between
    # its delimiters, on one line or several, without blockquote markers and indentation, trimmed.
    def math_blocks(text)
      out = []
      cur = nil
      text.each_line.with_index(1) do |l, n|
        s = l.sub(/\A(?:[ \t]*>)*[ \t]*/, "").chomp
        if cur&.key?(:mark)
          next cur[:lines] << l unless closes?(cur, l)
          out << { line: cur[:line], last: n, body: cur[:lines].join } if cur[:lang] == "math"
          cur = nil
        elsif cur
          next cur[:lines] << s unless s.end_with?("$$")
          out << { line: cur[:line], last: n, body: (cur[:lines] << s[0...-2]).join("\n").strip }
          cur = nil
        elsif (cur = opens(l, n))
          cur
        elsif s.start_with?("$$")
          rest = s[2..]
          next cur = { line: n, lines: [rest] } unless rest.size >= 2 && rest.end_with?("$$")
          out << { line: n, last: n, body: rest[0...-2].strip }
        end
      end
      out
    end

    # The _data/math file name of a page: math_key: from front matter, else the default-language source path
    # without its extension, with / as --. page_lang is a Modootoday::I18n::PageLang.
    def math_key(rel, page_lang, fm = {})
      given = fm.is_a?(Hash) ? fm["math_key"] : nil
      return given.to_s unless given.nil? || given.to_s.empty?
      page_lang.source(rel).sub(/\.[^.\/]+\z/, "").gsub("/", "--")
    end

    def opens(l, n)
      m = l.match(FENCE_OPEN)
      return nil unless m && !(m[1].start_with?("`") && l.count("`") > m[1].size)
      { mark: m[1], lang: m[2].downcase, line: n, lines: [] }
    end

    def closes?(cur, l) = l.match?(/\A {0,3}#{Regexp.escape(cur[:mark][0])}{#{cur[:mark].size},}\s*\z/)

    # The data-mt-src of an SVG's root element, or nil.
    def src_of(svg) = svg[SRC_ATTR, 1]

    # [width, height] of an SVG's viewBox, rounded up to whole pixels, or nil.
    def viewbox(svg)
      m = svg.match(VIEWBOX)
      m && [m[1].to_f.ceil, m[2].to_f.ceil]
    end
  end
end
