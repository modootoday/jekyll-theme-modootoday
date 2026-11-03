# frozen_string_literal: true

module Modootoday
  module Check
    # The modootoday: settings in the site's _config.yml; each key's rule is registered under config/keys/.
    module SiteConfig
      COMPONENTS = %w[callout badge hero cta card tabs code-copy nav sidebar page-actions pagination theme-toggle breadcrumb toc accordion steps figure timeline kbd search code footnotes progress embed banner filetree details faq params linkcards quote gallery pricing subscribe split loading figure-svg lists reveal bleed terminal visual filter].freeze
      SEMANTIC = %w[background foreground muted muted-foreground card card-foreground primary primary-foreground brand accent
                    accent-foreground border ring note tip important warning caution status-available status-partial
                    status-planned link link-hover font-sans font-mono font-heading heading-weight font-size line-height
                    measure space radius code-background code-foreground code-keyword code-string code-comment
                    code-function code-constant code-variable code-type code-number code-operator code-tag
                    code-attribute code-inserted code-deleted].freeze

      module_function

      def call(ctx)
        mtc, errs = ctx.mtc, ctx.errs
        return errs << "_config.yml: modootoday: must be a map" if mtc && !mtc.is_a?(Hash)
        return unless mtc.is_a?(Hash)
        Config::Schema.validate(ctx)
      end
    end
  end
end
