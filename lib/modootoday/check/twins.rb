# frozen_string_literal: true

module Modootoday
  module Check
    # 7. --twins: every Markdown page (except README.md and `twin: false`) has /<page>/index.md
    #    (/index.md for index.md), byte-identical to its source body. It comes from a stub <name>.md.txt
    #    (layout: twin; works on GitHub Pages) or from the opt-in plugin (plugins: [jekyll-theme-modootoday]).
    #    With modootoday.twins: source, a page without front matter is its own twin at /<path>.md.
    #    llms.txt / llms-full.txt exist at / and at each /<lang>/; llms-full.txt contains every page body.
    module Twins
      HINT = "add a stub %s (front matter `layout: twin`, `twin_of`, `permalink`) or enable `plugins: [jekyll-theme-modootoday]` (not on classic GitHub Pages)"

      module_function

      def call(ctx)
        return unless ctx.option?("--twins")
        bodies = Hash.new { |h, k| h[k] = [] }
        ctx.mds.each { |f| page(ctx, f, bodies) }
        llms(ctx, bodies)
      end

      def page(ctx, f, bodies)
        errs, site, rf = ctx.errs, ctx.site, ctx.rel(f)
        stub = "#{f}.txt"
        if File.exist?(stub)
          st = File.read(stub)
          meta = (Markdown.fm(st) rescue {})
          errs << "#{ctx.rel(stub)}: stub must set layout: twin" unless meta["layout"] == "twin"
          errs << "#{ctx.rel(stub)}: stub body must be empty" unless Markdown.body(st).strip.empty?
        end
        return if File.basename(f) == "README.md" || (Markdown.fm(File.read(f)) rescue {})["twin"] == false
        return if rf.split("/").include?("_posts") # posts: dated URLs, listed by the archive; no twin (documented limit)
        r = rf.delete_suffix(".md")
        if ctx.source_mode? && File.read(f) !~ Markdown::FM
          # front-matter-less mode: rendered page + raw copy of the whole source at its own path
          errs << "#{rf}.txt: redundant stub in twins: source mode (the source is already the twin); delete it" if File.exist?(stub)
          raw = "#{site}/#{rf}"
          html = ["#{site}/#{r}.html", "#{site}/#{r}/index.html"]
          bodies[ctx.lang_of(r).to_s] << [rf, File.read(f)]
          errs << "#{rf}: no rendered page (#{html.map { |h| h.delete_prefix("#{site}/") }.join(' or ')}); is jekyll-optional-front-matter enabled? (local builds: list it in plugins:)" unless html.any? { |h| File.exist?(h) }
          return errs << "#{rf}: raw copy missing at #{raw} (optional_front_matter.remove_originals must not be true)" unless File.exist?(raw)
          return errs << "#{raw}: raw copy is not byte-identical to #{rf}" unless File.binread(raw) == File.binread(f)
          return
        end
        out = File.basename(r) == "index" ? "#{site}/#{r}.md" : "#{site}/#{r}/index.md"
        b = Markdown.body(File.read(f))
        bodies[ctx.lang_of(r).to_s] << [rf, b]
        return errs << "#{rf}: twin missing at #{out}: #{format(HINT, "#{rf}.txt")}" unless File.exist?(out)
        errs << "#{out}: twin is not byte-identical to the body of #{rf}" unless File.binread(out) == b.b
      end

      def llms(ctx, bodies)
        langs = [""] + ctx.i18n.keys.select { |l| Dir.exist?("#{ctx.src}/#{l}") }
        langs.each do |l|
          %w[llms.txt llms-full.txt].each do |n|
            p = [ctx.site, l, n].reject(&:empty?).join("/")
            next ctx.errs << "#{p}: missing (per-language llms file; stub with `layout: #{n.delete_suffix('.txt')}` or the plugin)" unless File.exist?(p)
            txt = File.read(p)
            if n == "llms.txt"
              ctx.errs << "#{p}: must start with an H1 (llmstxt.org)" unless txt.start_with?("# ")
            else
              bodies[l].each { |(name, b)| ctx.errs << "#{p}: does not contain the body of #{name}" unless b.strip.empty? || txt.include?(b.strip) }
            end
          end
        end
      end
    end
  end
end
