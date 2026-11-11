# frozen_string_literal: true

require_relative "../../../stubs/page"

module Modootoday
  module Check
    # 7. --twins: every Markdown page (except README.md, `twin: false` and `layout: error`) has /<page>/index.md
    #    (/index.md for index.md), byte-identical to its source body. It comes from a stub <name>.md.txt
    #    (layout: twin; works on GitHub Pages) or from the opt-in plugin (plugins: [jekyll-theme-modootoday]).
    #    With modootoday.twins: source, a page without front matter is its own twin at /<path>.md.
    #    A reference page's packages: table is added to its twin as Markdown, before the body (or after it with
    #    packages_position: after); the body itself must still be there byte-for-byte.
    #    llms.txt / llms-full.txt exist at / and at /<lang>/ for each language with pages; llms-full.txt contains
    #    every page body of its language.
    module Twins
      HINT = "add a stub %s with front matter `layout: twin`, `twin_of: %s` and `permalink: %s` (`modootoday-stubs SRC --twins --write` " \
             "writes every missing stub) or enable `plugins: [jekyll-theme-modootoday]` (not on classic GitHub Pages); " \
             "a page that needs no twin sets `twin: false`"
      LLMS = "missing: add %s with only front matter `layout: %s`%s and no body, or enable `plugins: [jekyll-theme-modootoday]`"

      module_function

      def call(ctx)
        return unless ctx.option?("--twins")
        bodies = Hash.new { |h, k| h[k] = [] }
        ctx.mds.each { |f| page(ctx, f, bodies) }
        llms(ctx, bodies)
      end

      def page(ctx, f, bodies)
        errs, site, rf = ctx.errs, ctx.site, ctx.rel(f)
        # A stub sits next to its page, or under generated/ with path: set (the docs site).
        stub = ["#{f}.txt", "#{ctx.src}/generated/#{rf}.txt"].find { |s| File.exist?(s) } || "#{f}.txt"
        if File.exist?(stub)
          st = File.read(stub)
          meta = (Markdown.fm(st) rescue {})
          errs << "#{ctx.rel(stub)}: stub must set layout: twin" unless meta["layout"] == "twin"
          errs << "#{ctx.rel(stub)}: stub body must be empty" unless Markdown.body(st).strip.empty?
        end
        return if File.basename(f) == "README.md"
        return if rf.split("/").include?("_posts") # posts: dated URLs, listed by the archive; no twin (documented limit)
        src = File.read(f)
        fm = (Markdown.fm(src) rescue {})
        lang = ctx.lang_of(rf, fm)
        bodies[lang] # a language with pages has llms files, even when none of them has a twin
        return unless Stubs::Page.new(rf, fm.is_a?(Hash) ? fm : {}).twin?
        r = rf.delete_suffix(".md")
        if ctx.source_mode? && src !~ Markdown::FM
          # front-matter-less mode: rendered page + raw copy of the whole source at its own path
          errs << "#{rf}.txt: redundant stub in twins: source mode (the source is already the twin); delete it" if File.exist?(stub)
          raw = "#{site}/#{rf}"
          html = ["#{site}/#{r}.html", "#{site}/#{r}/index.html"]
          bodies[lang] << [rf, src]
          errs << "#{rf}: no rendered page (#{html.map { |h| h.delete_prefix("#{site}/") }.join(' or ')}); is jekyll-optional-front-matter enabled? (local builds: list it in plugins:)" unless html.any? { |h| File.exist?(h) }
          return errs << "#{rf}: raw copy missing at #{raw} (optional_front_matter.remove_originals must not be true)" unless File.exist?(raw)
          return errs << "#{raw}: raw copy is not byte-identical to #{rf}" unless File.binread(raw) == File.binread(f)
          return
        end
        out = twin_path(site, rf, r, fm)
        b = Markdown.body(src)
        bodies[lang] << [rf, b]
        return errs << "#{rf}: twin missing at #{out}: #{format(HINT, "#{rf}.txt", File.basename(rf), out.delete_prefix(site))}" unless File.exist?(out)
        tw = File.binread(out)
        pk = fm["layout"] == "reference" && fm["packages"].is_a?(Array) && !fm["packages"].empty? ? fm["packages"] : nil
        return errs << "#{out}: twin is not byte-identical to the body of #{rf}" unless pk || tw == b.b
        return unless pk
        after = fm["packages_position"] == "after"
        ok = after ? tw.start_with?(b.b) : tw.end_with?(b.b)
        names = pk.map { |x| x.is_a?(Hash) ? x["name"].to_s : "" }
        ok &&= names.all? { |n| tw.include?("`#{n}`".b) }
        errs << "#{out}: twin must be the body of #{rf} with its packages: table #{after ? 'after' : 'before'} it" unless ok
      end

      # A directory URL's twin is its index.md; a sibling translation (install.ko.md) has its URL in permalink:.
      def twin_path(site, rf, r, fm)
        return "#{site}/#{r}.md" if File.basename(r) == "index"
        "#{site}#{Stubs::Page.new(rf, fm.is_a?(Hash) ? fm : {}).url}index.md"
      end

      def llms(ctx, bodies)
        langs = [""] + ctx.i18n.keys.select { |l| bodies.key?(l) }
        langs.each do |l|
          %w[llms.txt llms-full.txt].each do |n|
            p = [ctx.site, l, n].reject(&:empty?).join("/")
            stub = [l, n].reject(&:empty?).join("/")
            next ctx.errs << "#{p}: #{format(LLMS, stub, n.delete_suffix('.txt'), l.empty? ? '' : " and `lang: #{l}`")}" unless File.exist?(p)
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
