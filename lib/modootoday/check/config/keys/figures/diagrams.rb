# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      # Static diagrams (front matter diagrams:): where the committed SVG pairs live, whether a dark twin exists, and
      # whether the Mermaid source stays on the page in a details element.
      module Diagrams
        KEYS = %w[dir dark source].freeze
        SOURCES = %w[details none].freeze
        DEFAULTS = { "dir" => "/assets/diagrams/", "dark" => true, "source" => "details" }.freeze

        module_function

        # The settings with the defaults the Liquid side uses (markdown/figures/diagrams.html).
        def settings(mtc)
          v = mtc.is_a?(Hash) && mtc["diagrams"].is_a?(Hash) ? mtc["diagrams"] : {}
          DEFAULTS.merge(v.slice(*KEYS).compact)
        end
      end

      shape = lambda do |ctx, path, v|
        (v.keys - Diagrams::KEYS).each { |k| ctx.errs << "_config.yml: #{path}: unknown key '#{k}' (known: #{Diagrams::KEYS.join(', ')})" }
        ctx.errs << "_config.yml: #{path}.dir must be a site path like /assets/diagrams/ (starts and ends with /)" if v.key?("dir") && !v["dir"].to_s.match?(Validate::SITE_PATH)
        ctx.errs << "_config.yml: #{path}.dark must be true or false" if v.key?("dark") && !Validate::BOOL.include?(v["dark"])
        ctx.errs << "_config.yml: #{path}.source must be #{Diagrams::SOURCES.join(' or ')} (got #{v['source'].inspect})" if v.key?("source") && !Diagrams::SOURCES.include?(v["source"])
      end
      Schema.register(Key.new(name: "diagrams", type: :map, message: "must be a map (dir:, dark:, source:)", check: shape))
    end
  end
end
