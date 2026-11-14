# frozen_string_literal: true

module Modootoday
  module Check
    # banner: {release: latest} reads site.github.latest_release when the site is built; with no published release (or no
    # GitHub metadata) the banner is silently left out. The built home page shows whether the build had one.
    module ReleaseBanner
      SHOWN = /class="mt-banner"/

      module_function

      def call(ctx)
        banner = ctx.mtc.is_a?(Hash) ? ctx.mtc["banner"] : nil
        return unless banner.is_a?(Hash) && banner["text"].nil? && banner["release"] == "latest"
        return if ctx.mtc["components"].is_a?(Array) && !ctx.mtc["components"].include?("banner")
        home = ctx.site && File.join(ctx.site, "index.html")
        return unless home && File.file?(home)
        html = File.read(home)
        return if html.match?(SHOWN) || !html.include?("/assets/css/modootoday.css")
        ctx.warns << "_config.yml: modootoday.banner.release: latest, but the build has no release banner: " \
                     "site.github.latest_release was empty (no published release, only prereleases, or no GitHub metadata in the build); " \
                     "publish a release and rebuild, set github: {latest_release: {tag_name, html_url}} in _config.yml as a stand-in, " \
                     "or give release: {version, url}"
      end
    end
  end
end
