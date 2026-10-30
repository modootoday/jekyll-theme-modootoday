# frozen_string_literal: true

module Modootoday
  module Check
    # Rules 0-1: front matter present, fence info strings, alerts, forbidden syntax, section headings.
    module PageSyntax
      KNOWN = %w[NOTE TIP IMPORTANT WARNING CAUTION].freeze
      NESTED_ALERT = "alert nested in list/table/quote (GitHub renders only top-level alerts; this shows as a plain quote); start '> [!TYPE]' at column 0"

      module_function

      # Returns the number of top-level '## ' headings (used by the sections: rule).
      def call(ctx, f, text, b, code)
        front_matter(ctx, f, text)
        fences(ctx, f, b)
        alerts(ctx, f, code.lines)
        html_free = Markdown.strip_comments(code)
        forbidden(ctx, f, code, html_free)
        headings(ctx, f, html_free)
      end

      # 0. every content page needs front matter (may be empty "---\n---"); without it,
      #    GitHub Pages (jekyll-optional-front-matter) renders the page AND copies the raw .md to _site.
      def front_matter(ctx, f, text)
        ctx.errs << "#{ctx.rel(f)}: missing front matter (add an empty '---' / '---' block at the top)" unless (text.start_with?("---\n") && text =~ Markdown::FM) || ctx.source_mode?
      end

      # 1a. code fence info string: one language word only (kramdown 2.4 turns "sh {x}" into inline code)
      def fences(ctx, f, b)
        Markdown.strip_fences(b) do |n, info|
          next if info.empty? || info.match?(/\A[\w#+.-]+\z/)
          ctx.errs << "#{ctx.rel(f)}:#{n}: code fence info string must be a single language word (got #{info.inspect}); attributes like {title=…} break kramdown"
        end
      end

      # 1b. alerts (GitHub extension): case-insensitive markers, registered types only
      def alerts(ctx, f, lines)
        errs, r = ctx.errs, ctx.rel(f)
        lines.each_with_index do |l, i|
          n = i + 1
          errs << "#{r}:#{n}: tab after '>' (kramdown reads it as an indented code block); use a space" if l =~ /^ {0,3}>\t/
          errs << "#{r}:#{n}: formatted alert marker (e.g. **[!NOTE]**) is not an alert anywhere; write > [!NOTE]" if l =~ /^ {0,3}> ?\*{1,2}\[!\w+\]/
          ctx.warns << "#{r}:#{n}: '[! TYPE]' with a space is not an alert (renders as a plain quote)" if l =~ /^ {0,3}> ?\[! +\w+\]/
          next unless (m = l.match(/^ {0,3}> ?\[!(\w+)\](.*)$/))
          t, after = m[1], m[2]
          next errs << "#{r}:#{n}: unregistered alert type [!#{t}] (allowed: #{KNOWN.join('/')}; any case)" unless KNOWN.include?(t.upcase)
          errs << "#{r}:#{n}: text after [!#{t}] (custom titles are not supported; GitHub shows a plain quote)" unless after.strip.empty?
          rest = lines[(i + 1)..].to_a.take_while { |x| x.strip != "" }
          errs << "#{r}:#{n}: empty alert [!#{t}] (GitHub shows a plain quote); add body text" if rest.all? { |x| x.sub(/^ {0,3}>/, "").strip.empty? }
        end
      end

      # Tool-generated region markers on their own line, e.g. <!-- spec:toc:begin --> / <!-- spec:toc:end -->
      MARKER = /^[ \t]*<!--[ \t]*[a-z][a-z0-9-]*(?::[a-z0-9._-]+)*:(?:begin|end)[ \t]*-->[ \t]*$/
      # specfold generated values, own-line or inline, one line each: <!-- spec:count -->12<!-- /spec:count -->
      SPEC = %r{<!--[ \t]*/?spec:[a-z0-9._-]+(?::[a-z0-9._-]+)*[ \t]*-->}

      # 1c. forbidden syntax outside code
      def forbidden(ctx, f, code, html_free)
        r = ctx.rel(f)
        ctx.errs << "#{r}: HTML comment <!-- --> (hidden on GitHub, emitted by kramdown); remove it" if code.gsub(MARKER, "").gsub(SPEC, "").include?("<!--")
        html_free.each_line.with_index(1) do |l, n|
          linkless = l.gsub(/\]\([^)]*\)/, "]()").gsub(/<(https?:|mailto:)[^>]*>|<[^@\s>]+@[^>\s]+>/, "<>").sub(/^ {0,3}\[[^\]]+\]:\s*\S+/, "")
          why = case l
                when /<\/?[a-zA-Z][\w-]*[\s>\/]/ then "raw HTML (not portable: GitHub renders some tags, strips others; kramdown passes all through)"
                when /\{%|\{\{/ then "Liquid"
                when /\{:/ then "kramdown IAL/ALD"
                when /\{#[\w-]+\}/ then "{#id} header id"
                when /^:\s/ then "definition list"
                when /^\*\[[^\]]+\]:/ then "abbreviation definition *[X]: (kramdown-only)"
                when /^\s*([-*+]|\d+\.|\|).*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/i, /^\s*(>\s*){2,}\[!/ then NESTED_ALERT
                end
          why ||= "bare URL/e-mail autolink (kramdown does not link it); write <https://…> or [text](url)" if linkless =~ %r{(?<![<\w/@.])(https?://|www\.)\S|(?<![<\w.+-])[\w.+-]+@[\w-]+\.[a-z]{2,}}i
          ctx.errs << "#{r}:#{n}: #{why}" if why
        end
      end

      # Section headings: only column-0 '## ' starts a section; returns how many there are.
      def headings(ctx, f, html_free)
        h2 = 0
        prev = ""
        list = false # inside a list item (last column-0 block started with a list marker)
        html_free.each_line.with_index(1) do |l, n|
          list = l =~ /^([-*+]|\d+[.)])\s/ ? true : false if l =~ /^\S/
          msg = case l
                when /^##( |$)/ then (h2 += 1; nil)
                when /^\s+##( |$)/
                  if list then "'##' inside a list item is not a section (sections split only on column-0 '## '); use '###' or move it out of the list"
                  elsif l =~ /^ {1,3}#/ then "indented '##' (kramdown: paragraph, GitHub: heading); start at column 0"
                  end
                when /^\s+> ?\[!\w+\]/ then list ? NESTED_ALERT : nil
                when /^\s*(>\s*)+##( |$)/ then "'##' inside a quote/alert is not a section (sections split only on column-0 '## '; GitHub would show an h2 inside the box); use '###' or bold text"
                when /^ {0,3}-+\s*$/
                  if prev =~ /\S/ && prev !~ /^\s*([-*+>|#]|\d+\.)/
                    n -= 1
                    "setext heading (text underlined with ---) is not allowed; use '## '"
                  end
                end
          ctx.errs << "#{ctx.rel(f)}:#{n}: #{msg}" if msg
          prev = l
        end
        h2
      end
    end
  end
end
