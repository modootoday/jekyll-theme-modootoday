# frozen_string_literal: true

require "json"
require_relative "../../../figures"

module Modootoday
  module Check
    # math.mode: static: the n-th ```math fence or $$ block of a page is the n-th entry {src:, html:} of
    # _data/math/<key>.yml (key: Figures.math_key; translations share their source's file). Inline math cannot be static.
    module MathStatic
      KEY = /\A[A-Za-z0-9_-]+\z/
      EXTS = %w[yml yaml json].freeze
      HINT = "render them again (modootoday-check SRC --math lists them)"

      module_function

      def call(ctx, f, text)
        return unless Renderers.static_math?(ctx.mtc)
        rec = record(ctx, f, text)
        return unless rec
        r = rec[:page]
        n = inline(text)
        ctx.errs << "#{r}:#{n}: inline math cannot be rendered ahead of time (modootoday.math.mode: static); make it a $$ block on its own lines or a ```math fence" if n
        return ctx.errs << "#{r}: math key #{rec[:key].inspect} is not a data file name Jekyll keeps; set math_key: to letters, digits, - and _" unless rec[:key].match?(KEY)
        data(ctx, r, rec)
      end

      # The entries against the blocks: the file, the count, each digest, KaTeX HTML without its stylesheet.
      def data(ctx, r, rec)
        blocks, list, file = rec[:blocks], rec[:data], rec[:file]
        return ctx.errs << "#{r}: #{blocks.size} math #{blocks.size == 1 ? 'block' : 'blocks'} but no #{file}; #{HINT}" if list.nil? && blocks.any?
        return if list.nil?
        return ctx.errs << "#{r}: #{file} must be a list of {src:, html:}, one per math block" unless list.is_a?(Array) && list.all? { |e| e.is_a?(Hash) }
        at = blocks.empty? ? "none" : "lines #{blocks.map { |b| b[:line] }.join(', ')}"
        ctx.errs << "#{r}: #{file} has #{list.size} #{list.size == 1 ? 'entry' : 'entries'} but the page has #{blocks.size} math #{blocks.size == 1 ? 'block' : 'blocks'} (#{at}); the n-th block is the n-th entry" if list.size != blocks.size
        blocks.zip(list).each_with_index do |(b, e), i|
          next unless b && e
          ctx.errs << "#{r}:#{b[:line]}: #{file} entry #{i + 1} has no html:" if e["html"].to_s.strip.empty?
          ctx.errs << "#{r}:#{b[:line]}: stale math: entry #{i + 1} of #{file} was rendered from other TeX than this block (#{b[:digest]}); pages with the same key share the file; #{HINT}" if e["src"] != b[:digest]
        end
        html = list.any? { |e| e["html"].to_s.include?("katex-html") }
        ctx.errs << "#{r}: #{file} holds KaTeX HTML output, which needs KaTeX's stylesheet: set modootoday.math.css or base, or render MathML" if html && !Renderers.math_urls(ctx.mtc["math"])["css"]
      end

      # One page: {page:, key:, file:, blocks: [{line:, tex:, digest:}], data:, reason:}; nil with math: false.
      def record(ctx, f, text)
        fm = Markdown.fm(text) rescue {}
        return nil if fm.is_a?(Hash) && fm["math"] == false
        body = Markdown.body(text)
        offset = text.lines.size - body.lines.size
        blocks = Figures.math_blocks(body).map { |b| { line: b[:line] + offset, tex: b[:body].chomp, digest: Figures.digest(b[:body]) } }
        rel = ctx.rel(f)
        key = Figures.math_key(rel, ctx.page_lang, fm)
        path = EXTS.map { |x| File.join(ctx.src, "_data/math/#{key}.#{x}") }.find { |p| File.file?(p) }
        list = path && load(path)
        reason = if list.nil? then ("missing" if blocks.any?) elsif !list.is_a?(Array) || list.size != blocks.size || blocks.zip(list).any? { |b, e| !e.is_a?(Hash) || e["src"] != b[:digest] } then "stale" end
        { page: rel, key: key, file: path ? ctx.rel(path) : "_data/math/#{key}.yml", blocks: blocks, data: list, reason: reason }
      end

      def load(path) = path.end_with?(".json") ? JSON.parse(File.read(path)) : YAML.safe_load(File.read(path))

      # Line of the first inline $…$ or $$…$$ (inside a sentence) outside code and math blocks, or nil.
      def inline(text)
        body = Markdown.body(text)
        offset = text.lines.size - body.lines.size
        inside = Figures.math_blocks(body).flat_map { |b| (b[:line]..b[:last]).to_a }
        Markdown.strip_code(body).each_line.with_index(1) do |l, n|
          next if inside.include?(n) || l =~ /\A {4}|\A\t/
          return n + offset if l.include?("$$") || l.gsub("$$", "") =~ Renderers::DOLLAR
        end
        nil
      end

      # --math: per data file whose page has missing or stale entries, the blocks to render, as JSON; 1 when any.
      def list(ctx)
        recs = Renderers.static_math?(ctx.mtc) ? ctx.mds.filter_map { |f| record(ctx, f, File.read(f)) } : []
        recs = recs.select { |x| x[:key].match?(KEY) }.group_by { |x| x[:key] }.values
        out = recs.map { |g| g.find { |x| !ctx.page_lang.translation?(x[:page]) } || g.first }.select { |x| x[:reason] }
        puts JSON.pretty_generate(out.map { |x| x.slice(:key, :file, :page, :blocks, :reason) })
        out.empty? ? 0 : 1
      end
    end
  end
end
