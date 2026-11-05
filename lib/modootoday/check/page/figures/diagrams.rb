# frozen_string_literal: true

require_relative "../../../figures"

module Modootoday
  module Check
    # Front matter diagrams: the n-th ```mermaid fence of the page is the n-th entry; each entry names a committed SVG
    # pair under modootoday.diagrams.dir (config/keys/figures/diagrams.rb) and carries the alt text.
    module FigureDiagrams
      KEYS = %w[name alt caption width height].freeze
      NAME = %r{\A(?!.*\.\.)[A-Za-z0-9][A-Za-z0-9._/-]*\z}

      module_function

      def call(ctx, f, text)
        fm = Markdown.fm(text) rescue nil
        return unless fm.is_a?(Hash) && fm.key?("diagrams")
        r = ctx.rel(f)
        list = fm["diagrams"]
        return ctx.errs << "#{r}: diagrams: must be a list of {name, alt, caption, width, height}, one per ```mermaid fence" unless list.is_a?(Array)
        body = Markdown.body(text)
        offset = text.lines.size - body.lines.size
        fences = Figures.fences(body, "mermaid")
        count(ctx, r, list, fences.map { |x| x[:line] + offset })
        cfg = Config::Diagrams.settings(ctx.mtc)
        list.each_with_index { |e, i| entry(ctx, r, "diagrams[#{i}]", e, cfg) }
        ctx.warns << "#{r}: diagrams: and mermaid: true together: the page shows the static figures, so the Mermaid loader never runs; remove mermaid: true" if fm["mermaid"] == true
      end

      def count(ctx, r, list, lines)
        return if lines.size == list.size
        at = lines.empty? ? "none" : "lines #{lines.join(', ')}"
        ctx.errs << "#{r}: diagrams: has #{list.size} #{list.size == 1 ? 'entry' : 'entries'} but the page has #{lines.size} ```mermaid #{lines.size == 1 ? 'fence' : 'fences'} (#{at}); the n-th fence is the n-th entry"
      end

      def entry(ctx, r, w, e, cfg)
        return ctx.errs << "#{r}: #{w} must be a map with name: and alt:" unless e.is_a?(Hash)
        (e.keys - KEYS).each { |k| ctx.errs << "#{r}: #{w}: unknown key #{k} (#{KEYS.join(', ')})" }
        name = e["name"]
        return ctx.errs << "#{r}: #{w}.name must be a file name without .svg under #{cfg['dir']}, such as flow or guide/flow (got #{name.inspect})" unless name.is_a?(String) && name.match?(NAME) && !name.end_with?(".svg")
        ctx.errs << "#{r}: #{w} (#{name}) needs alt: the text a reader gets instead of the picture; say what the diagram shows" if e["alt"].to_s.strip.empty?
        files(ctx, r, w, name, cfg).then { |light| size(ctx, r, w, e, light) }
      end

      # The light SVG (and the dark one with dark: true) must exist in the source; returns the light SVG's path or nil.
      def files(ctx, r, w, name, cfg)
        base = File.join(ctx.src, cfg["dir"].to_s, name)
        paths = cfg["dark"] == false ? ["#{base}.svg"] : ["#{base}.svg", "#{base}.dark.svg"]
        paths.reject { |p| File.file?(p) }.each { |p| ctx.errs << "#{r}: #{w}: #{ctx.rel(p)} not found (render the fence and commit the SVG)" }
        File.file?(paths.first) ? paths.first : nil
      end

      def size(ctx, r, w, e, light)
        given = %w[width height].select { |k| e.key?(k) }
        bad = given.reject { |k| e[k].is_a?(Integer) && e[k].positive? }
        bad.each { |k| ctx.errs << "#{r}: #{w}.#{k} must be a whole number of pixels (got #{e[k].inspect})" }
        return if given.size == 2 || !bad.empty?
        vb = light && Figures.viewbox(File.read(light))
        hint = vb ? "; its viewBox gives width: #{vb[0]}, height: #{vb[1]}" : ""
        ctx.warns << "#{r}: #{w} has no width and height, so the page shifts when the image loads#{hint}"
      end
    end
  end
end
