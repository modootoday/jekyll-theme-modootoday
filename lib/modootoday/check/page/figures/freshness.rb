# frozen_string_literal: true

require "json"
require_relative "../../../figures"

module Modootoday
  module Check
    # Whether each listed diagram's committed SVGs were drawn from the fence the page has now: an SVG whose data-mt-src
    # differs from the fence digest is stale. An SVG without data-mt-src is hand-made and not tracked.
    module FigureFreshness
      module_function

      def call(ctx, f, text)
        renders(ctx, f, text).each do |d|
          next unless d[:reason] == "stale"
          ctx.errs << "#{d[:page]}: #{d[:entry]} (#{d[:name]}): stale diagram: #{d[:stale].join(' and ')} #{d[:stale].size == 1 ? 'was' : 'were'} drawn from another fence than the one at line #{d[:line]} (#{d[:digest]}); render it again (modootoday-check SRC --diagrams lists it)"
        end
      end

      # --diagrams: every listed diagram whose SVG is missing or stale, as JSON on stdout; 1 when the list is not empty.
      def list(ctx)
        out = ctx.mds.flat_map { |f| renders(ctx, f, File.read(f)).select { |d| d[:reason] } }
        puts JSON.pretty_generate(out.map { |d| d.slice(:page, :name, :line, :fence, :digest, :files, :reason) })
        out.empty? ? 0 : 1
      end

      # One record per front matter entry that has a fence and a usable name.
      def renders(ctx, f, text)
        fm = Markdown.fm(text) rescue nil
        return [] unless fm.is_a?(Hash) && fm["diagrams"].is_a?(Array)
        body = Markdown.body(text)
        offset = text.lines.size - body.lines.size
        cfg = Config::Diagrams.settings(ctx.mtc)
        fences = Figures.fences(body, "mermaid")
        fm["diagrams"].each_with_index.filter_map do |e, i|
          name = e.is_a?(Hash) && e["name"]
          next unless fences[i] && name.is_a?(String) && name.match?(FigureDiagrams::NAME)
          record(ctx, cfg, ctx.rel(f), "diagrams[#{i}]", name, fences[i], offset)
        end
      end

      def record(ctx, cfg, page, entry, name, fence, offset)
        base = File.join(cfg["dir"].to_s, name).delete_prefix("/")
        files = { "default" => "#{base}.svg" }
        files["dark"] = "#{base}.dark.svg" unless cfg["dark"] == false
        digest = Figures.digest(fence[:body])
        paths = files.values.map { |p| File.join(ctx.src, p) }
        stale = paths.select { |p| File.file?(p) && (s = Figures.src_of(File.read(p))) && s != digest }
        reason = if paths.any? { |p| !File.file?(p) } then "missing" elsif stale.any? then "stale" end
        { page: page, entry: entry, name: name, line: fence[:line] + offset, fence: fence[:body].chomp, digest: digest,
          files: files, reason: reason, stale: stale.map { |p| ctx.rel(p) } }
      end
    end
  end
end
