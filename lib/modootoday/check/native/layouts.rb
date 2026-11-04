# frozen_string_literal: true

require "yaml"

module Modootoday
  module Check
    module Native
      # Every layout a page asks for, in front matter or in _config.yml defaults, must be a site or theme layout:
      # Jekyll only warns and writes the page without one. Names from other themes get their replacement (schema/compat/).
      module Layouts
        THEME = File.expand_path("../../../../_layouts", __dir__)
        COMPAT = File.expand_path("../../schema/compat", __dir__)
        NONE = [nil, false, "", "none", "null"].freeze

        module_function

        def call(ctx)
          known = names(THEME) | names("#{ctx.src}/_layouts")
          Array(ctx.site_cfg["defaults"]).each_with_index do |d, i|
            l = d.is_a?(Hash) && d["values"].is_a?(Hash) ? d["values"]["layout"] : nil
            report(ctx, "_config.yml: defaults[#{i}]", l, known)
          end
          Native.pages(ctx).each { |f, fm| report(ctx, ctx.rel(f), fm["layout"], known) }
        end

        # Jekyll's LayoutReader: every file under _layouts, named by its path without the last extension.
        def names(dir) = Dir.glob("**/*.*", base: dir).map { |f| f.split(".")[0..-2].join(".") }

        def report(ctx, where, layout, known)
          return if NONE.include?(layout) || known.include?(layout.to_s)
          ctx.errs << "#{where}: layout #{layout} does not exist in the site or the theme, so Jekyll writes the page without one#{hint(layout.to_s)}"
        end

        def hint(name)
          maps = compat.filter_map { |c| "#{c['layouts'][name]} (#{c['theme']})" if c["layouts"].is_a?(Hash) && c["layouts"][name] }
          maps.empty? ? "" : "; use #{maps.join(', ')}"
        end

        def compat = @compat ||= Dir.glob("#{COMPAT}/*.yml").sort.map { |f| YAML.safe_load(File.read(f)) || {} }
      end
    end
  end
end
