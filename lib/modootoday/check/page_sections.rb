# frozen_string_literal: true

module Modootoday
  module Check
    # Rules 3-4: the sections: list matches the '## ' headings, and each section's component
    # (from _data/components.yml) gets known, allowed and required params and its slot contract.
    module PageSections
      module_function

      THEME = File.expand_path("../../..", __dir__)

      def call(ctx, f, text, b, code, h2)
        errs, r = ctx.errs, ctx.rel(f)
        meta = begin Markdown.fm(text) rescue (errs << "#{r}: front matter YAML error"; {}) end
        secs = meta["sections"]
        return unless secs
        return errs << "#{r}: sections: must be a list" unless secs.is_a?(Array)
        code.scan(/<!--.*?-->/m) { |c| errs << "#{r}: '##' inside an HTML comment is not a heading" if c =~ /^##/ }
        errs << "#{r}: sections: has #{secs.size} item(s) but body has #{h2} top-level '## ' heading(s)" if secs.size != h2
        sec_md = section_markdown(b, code)
        secs.each_with_index { |s, i| ComponentRules.section(ctx, r, i, s, sec_md[i]) if s.is_a?(Hash) }
        components(ctx, r, secs, sec_md) if ctx.comps
        hero = meta["hero"]
        errs << "#{r}: hero: must be a map such as {visual: name}" if hero && !hero.is_a?(Hash)
        errs << "#{r}: hero.checks must be true or false" if hero.is_a?(Hash) && hero.key?("checks") && ![true, false].include?(hero["checks"])
        split_hero(errs, r, hero) if hero.is_a?(Hash) && hero.key?("c")
        visuals(ctx, r, secs, hero.is_a?(Hash) ? hero : nil)
      end

      # hero: {c: split, visual: <name>, side: start|end, ratio: "1:1"|"5:7"}: split is the only hero component.
      def split_hero(errs, r, hero)
        return errs << "#{r}: hero.c must be split (got #{hero['c'].inspect})" unless hero["c"] == "split"
        errs << "#{r}: hero split: needs visual: <name> (the _includes/sections/<name>.html shown beside the text)" unless hero["visual"].is_a?(String) && !hero["visual"].strip.empty?
        errs << "#{r}: hero.side=#{hero['side'].inspect} not in [\"start\", \"end\"]" if hero.key?("side") && !%w[start end].include?(hero["side"])
        errs << "#{r}: hero.ratio=#{hero['ratio'].inspect} not in [\"1:1\", \"5:7\"]" if hero.key?("ratio") && !%w[1:1 5:7].include?(hero["ratio"])
      end

      # reveal: is a boolean, bleed: is true, false or wide. visual: <name> and decor: <name> on a section item or on hero: needs _includes/sections/<name>.html in the site or the theme (showcase).
      def visuals(ctx, r, secs, hero)
        items = secs.each_with_index.map { |s, i| [s, "sections[#{i}]"] }
        items << [hero, "hero"] if hero
        items.each do |s, where|
          next unless s.is_a?(Hash)
          ctx.errs << "#{r}: #{where}.reveal must be true or false" if s.key?("reveal") && ![true, false].include?(s["reveal"])
          ctx.errs << "#{r}: #{where}.bleed must be true, false or wide" if s.key?("bleed") && ![true, false, "wide"].include?(s["bleed"])
          %w[visual decor].each do |key|
            next unless s.key?(key)
            v = s[key].to_s
            next ctx.errs << "#{r}: #{where}.#{key} must be an include name [a-z0-9_-] (got #{s[key].inspect})" unless v =~ /\A[a-z0-9][a-z0-9_-]*\z/
            ctx.errs << "#{r}: #{where}.#{key}: _includes/sections/#{v}.html not found" unless [ctx.src, THEME].any? { |d| File.exist?(File.join(d, "_includes/sections/#{v}.html")) }
          end
        end
      end

      # Markdown of each top-level ## section (index i = sections[i]): [code spans/fences blanked, raw]
      def section_markdown(b, code)
        bl = b.lines
        cl = code.lines
        starts = cl.each_index.select { |k| cl[k] =~ /^##(?: |$)/ }
        starts.each_with_index.map do |st, k|
          raw = bl[st + 1...(starts[k + 1] || bl.size)].to_a.join
          [cl[st + 1...(starts[k + 1] || cl.size)].to_a.join, raw]
        end
      end

      def components(ctx, r, secs, sec_md)
        errs = ctx.errs
        secs.each_with_index do |s, i|
          next unless s.is_a?(Hash) && s["c"]
          spec = ctx.comps[s["c"]]
          next errs << "#{r}: sections[#{i}] unknown component '#{s['c']}' (not in _data/components.yml)" unless spec
          params = spec["params"] || {}
          Slots.check_section(errs, r, i, s["c"], spec["slots"], sec_md[i])
          (ctx.part_uses[s["c"]] ||= []) << r if spec.is_a?(Hash) && spec["parts"].is_a?(Array)
          (s.keys - %w[c name visual decor reveal bleed]).each do |k|
            # with visual:, other keys are the visual include's own params (include.section.<key>)
            next if !params.key?(k) && s.key?("visual")
            next errs << "#{r}: sections[#{i}] #{s['c']}: unknown param '#{k}'" unless params.key?(k)
            allowed = params[k].is_a?(Hash) && params[k]["allowed"]
            errs << "#{r}: sections[#{i}] #{s['c']}.#{k}=#{s[k].inspect} not in #{allowed.inspect}" if allowed && !allowed.include?(s[k])
          end
          params.each do |k, p|
            errs << "#{r}: sections[#{i}] #{s['c']}: missing required param '#{k}'" if p.is_a?(Hash) && p["required"] && !s.key?(k)
          end
        end
      end
    end
  end
end
