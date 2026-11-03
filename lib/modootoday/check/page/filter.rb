# frozen_string_literal: true

module Modootoday
  module Check
    # filter: true or {facet: <column>} on a sections: item, or on a page without sections: (its first list or table).
    # The Markdown it governs needs a top-level list or table; facet needs a table with that many columns. Directory
    # layouts use filter: for their field filter and filter_text: for this one.
    module Filter
      DIRECTORY = %w[directory portfolio team jobs events sponsors integrations].freeze
      LIST = /^ {0,3}(?:[-*+]|\d{1,9}[.)])[ \t]/
      DELIM = /^ {0,3}\|?[ \t]*:?-+:?[ \t]*(?:\|[ \t]*:?-+:?[ \t]*)*\|?[ \t]*$/

      module_function

      def call(ctx, f, text, b, code)
        r = ctx.rel(f)
        meta = begin Markdown.fm(text) rescue {} end
        return unless meta.is_a?(Hash)
        secs = meta["sections"].is_a?(Array) ? meta["sections"] : nil
        if DIRECTORY.include?(meta["layout"])
          ctx.errs << "#{r}: filter_text must be true or false" if meta.key?("filter_text") && ![true, false].include?(meta["filter_text"])
        elsif meta.key?("filter")
          page_level(ctx, r, meta["filter"], secs, code)
        end
        return unless secs
        mds = PageSections.section_markdown(b, code)
        secs.each_with_index do |s, i|
          next unless s.is_a?(Hash) && s.key?("filter")
          w = "#{r}: sections[#{i}]"
          next ctx.errs << "#{w}: filter: does not go with c: split, whose text sits in its own column" if s["c"] == "split"
          item(ctx, w, s["filter"], mds[i] && mds[i][0])
        end
      end

      def page_level(ctx, r, v, secs, code)
        return ctx.errs << "#{r}: filter: on the page applies only without sections:; set it on the sections: item" if secs
        item(ctx, "#{r}: page", v, code)
      end

      def item(ctx, w, v, md)
        return if v == false
        facet = v.is_a?(Hash) ? v["facet"] : nil
        unless v == true || (v.is_a?(Hash) && v.keys == ["facet"] && facet.is_a?(Integer) && facet.positive?)
          return ctx.errs << "#{w}.filter must be true, false or {facet: <column number from 1>} (got #{v.inspect})"
        end
        md = md.to_s
        return ctx.errs << "#{w}.filter needs a list or table at the top level of its Markdown" unless md.match?(LIST) || table_columns(md)
        return unless facet
        cols = table_columns(md)
        return ctx.errs << "#{w}.filter.facet needs a table (a list has no columns)" unless cols
        ctx.errs << "#{w}.filter.facet is #{facet} but the table has #{cols} columns" if facet > cols
      end

      # Columns of the first GFM table: the cells of the row above the first delimiter row.
      def table_columns(md)
        lines = md.lines
        i = lines.index { |l| l.match?(DELIM) && l.include?("-") && l.include?("|") }
        return nil unless i && i.positive?
        lines[i - 1].strip.delete_prefix("|").delete_suffix("|").split("|", -1).size
      end
    end
  end
end
