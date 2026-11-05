# frozen_string_literal: true

require "digest"

module Modootoday
  # Static figures: the fences a page replaces with committed renders, and the one digest rule that ties a render to
  # its source (data-mt-src on the render's root). Any other tool that writes data-mt-src must follow digest exactly.
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
          if l =~ /\A {0,3}#{Regexp.escape(cur[:mark][0])}{#{cur[:mark].size},}\s*\z/
            out << { line: cur[:line], body: cur[:lines].join } if cur[:lang] == lang
            cur = nil
          else
            cur[:lines] << l
          end
        elsif (m = l.match(FENCE_OPEN)) && !(m[1].start_with?("`") && l.count("`") > m[1].size)
          cur = { mark: m[1], lang: m[2].downcase, line: n, lines: [] }
        end
      end
      out
    end

    # The data-mt-src of an SVG's root element, or nil.
    def src_of(svg) = svg[SRC_ATTR, 1]

    # [width, height] of an SVG's viewBox, rounded up to whole pixels, or nil.
    def viewbox(svg)
      m = svg.match(VIEWBOX)
      m && [m[1].to_f.ceil, m[2].to_f.ceil]
    end
  end
end
