# frozen_string_literal: true

module Modootoday
  module Check
    # Widgets: c: widget sections and `widget:<element>` paragraphs place a custom element that a modootoday.scripts entry
    # defines (element:). Props reach the element as JSON in data-props, so they are plain values; the section text is the
    # element's fallback, so a section needs a lead paragraph.
    module Widget
      SPAN = /\A`widget:([^`]*)`\z/

      module_function

      def call(ctx, f, text, b, code)
        r = ctx.rel(f)
        meta = begin Markdown.fm(text) rescue {} end
        meta = {} unless meta.is_a?(Hash)
        els = elements(ctx)
        inline(ctx, r, Markdown.strip_fences(b).lines, els)
        props(ctx, "#{r}: widget_props", meta["widget_props"], els) if meta.key?("widget_props")
        secs = meta["sections"].is_a?(Array) ? meta["sections"] : []
        return unless secs.any? { |s| s.is_a?(Hash) && s["c"] == "widget" }
        mds = PageSections.section_markdown(b, code)
        secs.each_with_index { |s, i| section(ctx, "#{r}: sections[#{i}] widget", s, mds[i], els) if s.is_a?(Hash) && s["c"] == "widget" }
      end

      def elements(ctx)
        scripts = ctx.mtc.is_a?(Hash) && ctx.mtc["scripts"].is_a?(Hash) ? ctx.mtc["scripts"] : {}
        scripts.values.filter_map { |e| e["element"] if e.is_a?(Hash) && e["element"].is_a?(String) }
      end

      def inline(ctx, r, lines, els)
        lines.each do |l|
          v = l.strip[SPAN, 1]
          next unless v
          ctx.errs << "#{r}: `widget:#{v}`: no modootoday.scripts entry has element: #{v}, so it stays a code span" unless els.include?(v)
        end
      end

      def props(ctx, w, v, els)
        return ctx.errs << "#{w} must be a map of element names to props maps" unless v.is_a?(Hash)
        v.each do |el, p|
          ctx.warns << "#{w}.#{el}: no modootoday.scripts entry has element: #{el}" unless els.include?(el)
          plain(ctx, "#{w}.#{el}", p)
        end
      end

      def plain(ctx, w, p)
        return ctx.errs << "#{w} must be a map of names to plain values" unless p.is_a?(Hash)
        bad = p.reject { |_, x| x.nil? || x.is_a?(String) || x.is_a?(Numeric) || x == true || x == false }.keys
        ctx.errs << "#{w}: #{bad.join(', ')} must be a plain value (text, a number, true or false)" unless bad.empty?
      end

      # With a _data/components.yml widget row, the registry checks the required param and the lead slot.
      def section(ctx, w, s, md, els)
        el = s["widget"]
        own = !(ctx.comps.is_a?(Hash) && ctx.comps.key?("widget"))
        ctx.errs << "#{w}: needs widget: <element> (the element: of a modootoday.scripts entry)" if own && !(el.is_a?(String) && !el.empty?)
        ctx.errs << "#{w}: widget: #{el} is not the element: of any modootoday.scripts entry" if el.is_a?(String) && !el.empty? && !els.include?(el)
        plain(ctx, "#{w}.props", s["props"]) if s.key?("props")
        return unless own
        problem = Slots.count_problem("lead", { "min" => 1 }, md)
        ctx.errs << "#{w}: needs a paragraph after the heading, the text shown until the widget runs" if problem
      end
    end
  end
end
