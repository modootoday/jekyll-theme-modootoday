# frozen_string_literal: true

require_relative "../../../stubs/page"

module Modootoday
  module Check
    # --aliases: the URL aliases modootoday.aliases declares exist for every page with a directory URL other than /.
    #   md: /<page>.md, byte-identical to the page's twin. html: /<page>.html, a redirect whose refresh target and
    #   canonical are the page URL. Two pages with the same alias, or an alias over another source file, are errors.
    module Aliases
      HINT = "run modootoday-stubs SRC --aliases --write"
      REFRESH = /<meta http-equiv="refresh" content="0; url=([^"]*)">/
      CANONICAL = /<link rel="canonical" href="([^"]*)">/

      module_function

      def call(ctx)
        return unless ctx.option?("--aliases")
        cfg = ctx.mtc["aliases"]
        return ctx.errs << "--aliases: modootoday.aliases declares no alias (set md: true and/or html: true)" unless cfg.is_a?(Hash) && cfg.values.include?(true)
        seen = {}
        ctx.mds.each { |f| page(ctx, f, cfg, seen) }
      end

      def page(ctx, f, cfg, seen)
        rf = ctx.rel(f)
        src = File.read(f)
        return unless src.match?(Markdown::FM) && File.basename(f) != "README.md" && !rf.split("/").include?("_posts")
        fm = (Markdown.fm(src) rescue {})
        url = page_url(rf, fm)
        return if url.nil? || url == "/" || fm["layout"] == "redirect"
        %w[md html].each do |k|
          next unless cfg[k] == true
          next if k == "md" && fm["twin"] == false
          a = "#{url.chomp("/")}.#{k}"
          next ctx.errs << "#{rf}: alias #{a} is also the alias of #{seen[a]}" if seen.key?(a)
          seen[a] = rf
          next ctx.errs << "#{rf}: alias #{a} collides with the source file #{a.delete_prefix("/")}" if a.delete_prefix("/") != rf && File.exist?("#{ctx.src}#{a}")
          k == "md" ? md(ctx, rf, url, src, a) : html(ctx, rf, url, a)
        end
      end

      # Directory URLs only, as in modootoday-stubs: a permalink such as /404.html has no alias.
      def page_url(rf, fm)
        page = Stubs::Page.new(rf, fm)
        page.directory_url? ? page.url : nil
      end

      def md(ctx, rf, url, src, a)
        out = "#{ctx.site}#{a}"
        return ctx.errs << "#{rf}: md alias missing at #{out}: #{HINT}" unless File.exist?(out)
        twin = "#{ctx.site}#{url}index.md"
        want = File.exist?(twin) ? File.binread(twin) : Markdown.body(src).b
        ctx.errs << "#{out}: md alias is not byte-identical to the twin of #{rf}" unless File.binread(out) == want
      end

      def html(ctx, rf, url, a)
        out = "#{ctx.site}#{a}"
        return ctx.errs << "#{rf}: html alias missing at #{out}: #{HINT}" unless File.exist?(out)
        body = File.read(out)
        to, canon = body[REFRESH, 1].to_s, body[CANONICAL, 1]
        want = "#{base(ctx, to, url)}#{url}"
        ctx.errs << "#{out}: html alias must redirect to #{want} (got #{to.inspect})" unless to == want
        ctx.errs << "#{out}: html alias canonical must be the page URL #{want} (got #{canon.inspect})" unless at?(canon, want)
      end

      # The configured baseurl; without one, the prefix the build used (GitHub Pages sets it for project sites).
      def base(ctx, to, url)
        cfg = ctx.site_cfg["baseurl"].to_s.chomp("/")
        return cfg unless cfg.empty? && to.end_with?(url)
        prefix = to.delete_suffix(url)
        prefix.match?(%r{\A(/[^\s/]+)*\z}) ? prefix : ""
      end

      # The page path itself, or an absolute URL on any host with that path (GitHub Pages fills in site.url).
      def at?(value, path) = value == path || value.to_s.match?(%r{\Ahttps?://[^/]+#{Regexp.escape(path)}\z})
    end
  end
end
