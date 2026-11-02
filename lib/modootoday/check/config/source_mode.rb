# frozen_string_literal: true

module Modootoday
  module Check
    module SiteConfig
      module_function

      # twins: source needs Jekyll's raw copies of front-matter-less pages.
      def source_mode(ctx)
        return unless ctx.source_mode?
        cfg = ctx.site_cfg
        of = cfg["optional_front_matter"] || {}
        ctx.errs << "_config.yml: modootoday.twins: source needs the raw copies; remove optional_front_matter.remove_originals" if of.is_a?(Hash) && of["remove_originals"] == true
        ctx.errs << "_config.yml: modootoday.twins: source conflicts with require_front_matter: true" if cfg["require_front_matter"] == true
      end
    end
  end
end
