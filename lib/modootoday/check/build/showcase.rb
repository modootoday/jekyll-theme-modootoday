# frozen_string_literal: true

module Modootoday
  module Check
    # The showcase of a starter demo: _config.demo.yml's modootoday.showcase is checked like _config.yml's, and in a build
    # that shows it every built page should carry the robots noindex the default layout writes. A site made from a starter
    # keeps _config.demo.yml but builds without it, so no page has the showcase and nothing is reported.
    module ShowcaseBuild
      NOINDEX = /<meta name="robots" content="[^"]*noindex/
      SHOWN = / data-mt-showcase="/

      module_function

      def call(ctx)
        Config::Showcase.demo(ctx)
        return unless ctx.site && File.directory?(ctx.site) && Config::Showcase.enabled?(ctx)
        pages = Dir.glob("#{ctx.site}/**/*.html").sort.to_h { |f| [f, File.read(f)] }.select { |_, html| html.include?("<head") }
        return unless pages.values.any? { |html| html.match?(SHOWN) }
        pages.each do |f, html|
          next if html.match?(NOINDEX)
          ctx.warns << "#{f.delete_prefix("#{ctx.site}/")}: no robots noindex meta although modootoday.showcase is enabled " \
                       "(a layout that does not extend the theme's default)"
        end
      end
    end
  end
end
