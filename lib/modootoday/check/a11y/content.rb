# frozen_string_literal: true

module Modootoday
  module Check
    # Authoring-side screen-reader rules (WCAG 1.1.1, 1.3.1, 2.4.4, 4.1.1-style ids) on one page's Markdown,
    # code already blanked. Errors: images with no alt, empty links, duplicate ids. Warnings: heading skips,
    # vague link text, empty Markdown alt (decorative is allowed but should be deliberate).
    module A11yContent
      # English list mirrors Lighthouse SEO "link-text" (a hit there costs the SEO score).
      VAGUE = /\A(click here|click this|here|right here|more|read more|learn more|see more|more info|more information|information|go|start|this|continue|link|여기|여기를 클릭|더 보기|こちら|ここ|詳しくはこちら)\z/i

      module_function

      def call(ctx, f, code)
        r = ctx.rel(f)
        images(ctx, r, code)
        links(ctx, r, code)
        headings(ctx, r, code)
        ids(ctx, r, code)
      end

      def each_line(code, re)
        code.each_line.with_index(1) { |l, n| l.scan(re) { yield n, Regexp.last_match } }
      end

      def images(ctx, r, code)
        each_line(code, /<img\b(?![^>]*\balt=)[^>]*>/i) { |n, _| ctx.errs << "#{r}:#{n}: <img> without alt (screen readers read the file name); add alt=\"…\" or alt=\"\" if decorative" }
        each_line(code, /!\[\s*\]\(/) { |n, _| ctx.warns << "#{r}:#{n}: image with empty alt ![](…) is treated as decorative; describe it unless it adds no information" }
      end

      def links(ctx, r, code)
        each_line(code, /(?<!!)\[([^\]]*)\]\([^)]*\)/) do |n, m|
          t = m[1].gsub(/[*_`]/, "").strip
          next ctx.errs << "#{r}:#{n}: empty link text [](…) (announced as just \"link\"); write what it opens" if t.empty?
          ctx.warns << "#{r}:#{n}: vague link text \"#{t}\"; name the destination so it makes sense out of context" if t.match?(VAGUE)
        end
        each_line(code, %r{<a\b[^>]*>\s*</a>}i) { |n, _| ctx.errs << "#{r}:#{n}: empty <a></a> link" }
      end

      # The layout supplies the page <h1> (title); content starts at ## and must not skip levels.
      def headings(ctx, r, code)
        prev = 1
        code.each_line.with_index(1) do |l, n|
          next unless (m = l.match(/^ {0,3}(#{"#"}{1,6})\s+\S/))
          lv = m[1].size
          ctx.warns << "#{r}:#{n}: heading jumps from h#{prev} to h#{lv}; screen-reader users navigate by level, do not skip" if lv > prev + 1
          prev = lv
        end
      end

      def ids(ctx, r, code)
        seen = Hash.new(0)
        each_line(code, /\bid=["']([^"']+)["']/) { |n, m| ctx.errs << "#{r}:#{n}: duplicate id=\"#{m[1]}\" (breaks labels, skip links and anchors)" if (seen[m[1]] += 1) == 2 }
      end
    end
  end
end
