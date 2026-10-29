# frozen_string_literal: true

module Modootoday
  module Check
    # Values the transforms need (Rule 2b): inline `file:`, `progress:`, `embed:` code spans, and per-section
    # content rules for c: gallery, quote, pricing and subscribe that slot counts cannot express.
    module ComponentRules
      SKELETONS = %w[text card image avatar row].freeze

      module_function

      def inline(ctx, r, b)
        errs, lines = ctx.errs, Markdown.strip_fences(b).lines
        text = lines.join
        text.scan(/`progress:([^`]*)`/) do |(v)|
          errs << "#{r}: `progress:#{v}` must be a whole number from 0 to 100" unless v =~ /\A(100|[1-9]?\d)\z/
        end
        text.scan(/`skeleton:([^`]*)`/) do |(v)|
          errs << "#{r}: `skeleton:#{v}` must be one of #{SKELETONS.join(', ')}" unless SKELETONS.include?(v)
        end
        text.scan(/`embed:([^`]*)`/) do |(v)|
          errs << "#{r}: `embed:#{v}` must be an https:// URL, optionally followed by a title" unless v =~ %r{\Ahttps://[^\s"<>]+( [^"<>]+)?\z}
        end
        rl = b.lines
        rl.each_with_index do |l, i|
          next unless (fm = l.strip.match(/\A`file:([^`]*)`\z/))
          nxt = rl[(i + 1)..].to_a.find { |x| x.strip != "" }.to_s
          errs << "#{r}: `file:#{fm[1]}` must be alone in a paragraph right before a fenced code block" unless nxt =~ /\A\s*(```|~~~)/ && fm[1] !~ /\s/
        end
      end

      def section(ctx, r, i, s, md)
        errs, (m, _raw) = ctx.errs, md || ["", ""]
        w = "#{r}: sections[#{i}] #{s['c']}"
        case s["c"]
        when "gallery"
          imgs = m.scan(/^[-*+]\s+(.*)$/).flatten
          errs << "#{w}: each list item must be one image ![alt](src) with alt text" unless imgs.all? { |x| x.strip =~ /\A!\[[^\]\n]*\S[^\]\n]*\]\([^)\s]+\)\z/ }
          errs << "#{w}: write the image list without blank lines between items" if m =~ /^[-*+]\s.*\n\s*\n[-*+]\s/
        when "quote"
          errs << "#{w}: needs a > quote whose last line is the attribution (> — Name)" unless m =~ /^>\s*— \S/
        when "pricing"
          n = m.scan(/^###(?: |$)/).size
          rec = s["recommended"]
          errs << "#{w}: recommended: must be a plan number from 1 to #{n}" if s.key?("recommended") && !(rec.is_a?(Integer) && rec.between?(1, n))
        when "subscribe"
          act = ctx.mtc.is_a?(Hash) && ctx.mtc.dig("subscribe", "action")
          ctx.warns << "#{w}: no form is shown until _config.yml sets modootoday.subscribe.action" unless act
          errs << "#{w}: modootoday.subscribe.action must be an https:// URL" if act && act.to_s !~ %r{\Ahttps://\S+\z}
        end
      end
    end
  end
end
