# frozen_string_literal: true

require "json"

module Modootoday
  module Check
    # Charts: a `chart:<type> [stacked] [horizontal]` paragraph right before a GFM table, and c: chart sections with a
    # table or data: <name> (_data/charts/<name>.yml or .json: {labels, series: [{name, values}]}). The table is the
    # chart's fallback, so its cells should be numbers once , and % are removed.
    module Chart
      TYPES = %w[bar line area pie doughnut].freeze
      OPTS = %w[stacked horizontal].freeze
      NUMBER = /\A-?\d+(\.\d+)?\z/
      SPAN = /\A`chart:([^`]*)`\z/

      module_function

      def call(ctx, f, text, b, code)
        r = ctx.rel(f)
        inline(ctx, r, Markdown.strip_fences(b).lines)
        meta = begin Markdown.fm(text) rescue {} end
        secs = meta.is_a?(Hash) && meta["sections"].is_a?(Array) ? meta["sections"] : []
        return unless secs.any? { |s| s.is_a?(Hash) && s["c"] == "chart" }
        mds = PageSections.section_markdown(b, code)
        secs.each_with_index { |s, i| section(ctx, "#{r}: sections[#{i}] chart", s, mds[i] && mds[i][1]) if s.is_a?(Hash) && s["c"] == "chart" }
      end

      def enabled?(ctx) = ctx.mtc.is_a?(Hash) && ctx.mtc["chart"].is_a?(Hash) && ctx.mtc["chart"]["enabled"] == true

      def inline(ctx, r, lines)
        spans = lines.each_index.select { |i| lines[i].strip.match?(SPAN) }
        return if spans.empty?
        return ctx.warns << "#{r}: `chart:` stays a code span until _config.yml sets modootoday.chart.enabled: true" unless enabled?(ctx)
        spans.each do |i|
          v = lines[i].strip[SPAN, 1]
          w = "#{r}: `chart:#{v}`"
          words = v.split
          next ctx.errs << "#{w}: the type must be one of #{TYPES.join(', ')}" unless TYPES.include?(words.first)
          bad = words.drop(1) - OPTS
          next ctx.errs << "#{w}: unknown option #{bad.join(', ')} (#{OPTS.join(', ')})" unless bad.empty?
          rows = table_after(lines, i + 1)
          next ctx.errs << "#{w} must be alone in a paragraph right before a table" unless rows
          cells(ctx, w, rows)
        end
      end

      # Body rows of the GFM table that starts at the next non-blank line, or nil when there is none.
      def table_after(lines, from)
        k = (from...lines.size).find { |j| lines[j].strip != "" }
        return nil unless k && lines[k].include?("|") && lines[k + 1].to_s.match?(Filter::DELIM) && lines[k + 1].include?("-")
        lines[(k + 2)..].to_a.take_while { |l| l.strip != "" && l.include?("|") }.map { |l| l.strip.delete_prefix("|").delete_suffix("|").split("|", -1).map(&:strip) }
      end

      def cells(ctx, w, rows)
        rows.each_with_index do |row, n|
          bad = row.drop(1).find { |c| !number?(c) }
          ctx.warns << "#{w}: row #{n + 1} cell '#{bad}' is not a number" if bad
        end
      end

      def number?(v) = v.to_s.delete(",%").strip.match?(NUMBER)

      def section(ctx, w, s, md)
        errs = ctx.errs
        unless ctx.comps.is_a?(Hash) && ctx.comps.key?("chart")
          errs << "#{w}: type must be one of #{TYPES.join(', ')}" unless TYPES.include?(s["type"])
          %w[stacked horizontal].each { |k| errs << "#{w}: #{k} must be true or false" if s.key?(k) && ![true, false].include?(s[k]) }
        end
        table = md && Filter.table_columns(md)
        return errs << "#{w}: needs a table or data: <name> (_data/charts/<name>.yml)" if !table && !s.key?("data")
        return errs << "#{w}: has a table and data:; keep one" if table && s.key?("data")
        return cells(ctx, w, table_after(md.lines, md.lines.index { |l| l.match?(Filter::DELIM) && l.include?("-") } - 1).to_a) if table
        data(ctx, w, s["data"])
      end

      def data(ctx, w, name)
        file = Dir.glob("#{ctx.src}/_data/charts/#{name}.{yml,yaml,json}").first if name.is_a?(String) && name.match?(/\A[\w-]+\z/)
        return ctx.errs << "#{w}: data: #{name.inspect} needs _data/charts/#{name}.yml (or .json)" unless file
        d = begin File.extname(file) == ".json" ? JSON.parse(File.read(file)) : YAML.safe_load(File.read(file)) rescue nil end
        labels = d.is_a?(Hash) ? d["labels"] : nil
        series = d.is_a?(Hash) ? d["series"] : nil
        ok = labels.is_a?(Array) && !labels.empty? && series.is_a?(Array) && !series.empty? &&
             series.all? { |x| x.is_a?(Hash) && x["name"] && x["values"].is_a?(Array) && x["values"].size == labels.size }
        return ctx.errs << "#{w}: #{ctx.rel(file)} must be {labels: [...], series: [{name, values}]} with one value per label" unless ok
        bad = series.flat_map { |x| x["values"] }.reject { |v| number?(v) }
        ctx.warns << "#{w}: #{ctx.rel(file)} value #{bad.first.inspect} is not a number" unless bad.empty?
      end
    end
  end
end
