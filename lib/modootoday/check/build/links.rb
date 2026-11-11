# frozen_string_literal: true

require "cgi"

module Modootoday
  module Check
    # --links: every same-site a href, link href, img src, script src and source srcset in the built site points
    # at a file that exists, and a #fragment matches an id or a[name] on its target page. External URLs are not
    # fetched. Warnings, which --strict turns into failures (adr:modootoday/20261111231457). Needs Nokogiri.
    module Links
      TARGETS = "a[href], link[href], img[src], script[src], source[srcset]"
      EXTERNAL = %r{\A[a-z][a-z0-9+.-]*:|\A//}i

      module_function

      def call(ctx)
        return unless ctx.option?("--links")
        return ctx.warns << "--links needs the nokogiri gem; links were not checked" unless nokogiri?
        found = scan(ctx.site, baseurl(ctx))
        found[:problems].each { |p| ctx.warns << p }
      end

      def nokogiri?
        require "nokogiri"
        true
      rescue LoadError
        false
      end

      def baseurl(ctx) = ctx.site_cfg["baseurl"].to_s.chomp("/")

      # One pass over SITE; returns the problems and the external URLs it skipped.
      def scan(site, baseurl, &each_page)
        ids = Hash.new { |h, f| h[f] = Nokogiri::HTML(File.read(f)).css("[id],a[name]").map { |n| n["id"] || n["name"] } }
        problems, external = [], []
        Dir.glob(File.join(site, "**/*.html")).sort.each do |file|
          rel = file.delete_prefix(site)
          doc = Nokogiri::HTML(File.read(file))
          each_page&.call(rel, doc)
          doc.css(TARGETS).each do |n|
            url = (n["href"] || n["src"] || n["srcset"].to_s.split(/\s+/).first).to_s.strip
            next if url.empty?
            next external << url if url.match?(EXTERNAL)
            problem = link(site, baseurl, file, rel, url, ids)
            problems << problem if problem
          end
        end
        { problems: problems, external: external.uniq.sort }
      end

      def link(site, baseurl, file, rel, url, ids)
        upath, frag = url.split("#", 2)
        upath = upath.to_s.split("?", 2).first.to_s
        target = file
        unless upath.empty?
          path = upath.start_with?("/") ? upath : File.expand_path(upath, File.dirname("#{baseurl}#{rel}"))
          path += "/" if upath.end_with?("/") && !path.end_with?("/")
          return "#{rel}: #{url} is outside baseurl #{baseurl}" unless baseurl.empty? || path == baseurl || path.start_with?("#{baseurl}/")
          target = resolve(site, path.delete_prefix(baseurl))
          return "#{rel}: broken link #{url}" unless target
        end
        return if frag.nil? || frag.empty? || !target.end_with?(".html")
        "#{rel}: missing anchor #{url}" unless ids[target].include?(CGI.unescape(frag))
      end

      def resolve(site, path)
        full = File.join(site, CGI.unescape(path))
        return full if File.file?(full)
        return File.join(full, "index.html") if File.file?(File.join(full, "index.html"))
        "#{full}.html" if File.file?("#{full}.html")
      end
    end
  end
end
