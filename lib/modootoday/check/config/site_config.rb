# frozen_string_literal: true

module Modootoday
  module Check
    # The modootoday: settings in the site's _config.yml; each key's rule is registered under config/keys/.
    module SiteConfig
      # A-Z by id (adr:modootoday/20261109141344).
      COMPONENTS = %w[accordion badge banner bleed breadcrumb callout card chart code code-copy cta details diagram embed faq figure figure-svg filetree filter footer footnotes gallery hero install kbd linkcards lists loading nav page-actions pagination params pricing progress quote reveal search showcase sidebar split steps subscribe table table-stack tabs terminal theme-toggle timeline toc visual widget].freeze
      SEMANTIC = %w[background foreground muted muted-foreground card card-foreground primary primary-foreground brand accent
                    accent-foreground border border-input ring note tip important warning caution status-available status-partial
                    status-planned link link-hover font-sans font-mono font-heading heading-weight font-size line-height
                    measure narrow space radius code-background code-foreground code-keyword code-string code-comment
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
