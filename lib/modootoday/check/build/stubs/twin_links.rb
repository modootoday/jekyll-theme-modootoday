# frozen_string_literal: true

require "uri"

module Modootoday
  module Check
    # The twin and llms-full layouts point each relative link that names a source file at its target's site URL
    # (adr:modootoday/20261114115001), so a twin equals its source body with link targets masked, and every
    # target that differs from the source must reach a file in the built site.
    module TwinLinks
      TARGET = /(\]\()([^)\s]+)|^( {0,3}\[[^\]^][^\]]*\]: )(\S+)/

      module_function

      def mask(text) = text.gsub(TARGET) { "#{Regexp.last_match(1) || Regexp.last_match(3)}\0" }

      def targets(text) = text.scan(TARGET).map { |a| a[1] || a[3] }

      def same?(twin, body) = twin == body || mask(twin) == mask(body)

      # Rewritten targets of TWIN that reach no file; BODY is its source body. A packages: table placed :before or
      # :after the body adds links of its own, which are left out.
      def broken(ctx, body, twin, table: nil)
        base = ctx.site_cfg["baseurl"].to_s.chomp("/")
        src, out = targets(body), targets(twin)
        out = table == :after ? out.first(src.size) : out.last(src.size)
        src.zip(out).filter_map { |(s, t)| t if t && s != t && !reaches?(ctx.site, base, t) }
      end

      def reaches?(site, base, url)
        path = URI::DEFAULT_PARSER.unescape(URI.parse(url.sub(/[#?].*/m, "")).path.to_s)
        return false unless path.start_with?("#{base}/")
        f = File.join(site, path.delete_prefix(base))
        File.file?(f) || File.file?(File.join(f, "index.html"))
      rescue URI::InvalidURIError, ArgumentError
        false
      end
    end
  end
end
