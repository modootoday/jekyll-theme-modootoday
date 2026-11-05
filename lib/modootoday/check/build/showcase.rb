# frozen_string_literal: true

module Modootoday
  module Check
    # The showcase of a starter demo: _config.demo.yml's modootoday.showcase is checked like _config.yml's, and with the
    # showcase enabled every built page should carry the robots noindex the default layout writes.
    module ShowcaseBuild
      NOINDEX = /<meta name="robots" content="[^"]*noindex/

      module_function

      def call(ctx)
        Config::Showcase.demo(ctx)
        return unless ctx.site && File.directory?(ctx.site) && Config::Showcase.enabled?(ctx)
        Dir.glob("#{ctx.site}/**/*.html").sort.each do |f|
          html = File.read(f)
          next if !html.include?("<head") || html.match?(NOINDEX)
          ctx.warns << "#{f.delete_prefix("#{ctx.site}/")}: no robots noindex meta although modootoday.showcase is enabled " \
                       "(a layout that does not extend the theme's default)"
        end
      end
    end
  end
end
