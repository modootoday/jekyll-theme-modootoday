# frozen_string_literal: true

module Modootoday
  module Check
    module Native
      # A collection document without a layout is written without the theme: jekyll-default-layout (on in GitHub Pages)
      # sets layouts only for pages and posts. A warning per output collection, naming a layout for its defaults: the
      # detail page of a theme list layout named like the collection (its mt_self_detail), else doc.
      module Collections
        THEME = File.expand_path("../../../../_layouts", __dir__)

        module_function

        def call(ctx)
          cols = ctx.site_cfg["collections"]
          return unless cols.is_a?(Hash)
          cols.each do |label, c|
            next unless c.is_a?(Hash) && c["output"] == true && label != "posts" && !defaulted?(ctx, label)
            bare = docs(ctx, label).reject { |_, fm| fm.key?("layout") }
            report(ctx, label, bare.size) unless bare.empty?
          end
        end

        def report(ctx, label, n)
          list = "#{THEME}/#{label}.html"
          layout = (File.file?(list) && Markdown.fm(File.read(list))["mt_self_detail"]) || "doc"
          ctx.warns << "_config.yml: collections.#{label}: #{n} document(s) have no layout, so Jekyll writes them without the theme " \
                       "(jekyll-default-layout covers only pages and posts); set defaults: [{scope: {type: #{label}}, values: {layout: #{layout}}}]"
        end

        def docs(ctx, label)
          dir = File.join(ctx.src, ctx.site_cfg["collections_dir"].to_s, "_#{label}")
          Native.pages(ctx).select { |f, _| f.start_with?("#{dir}/") }
        end

        # A defaults entry with a layout whose scope covers the collection: its type, or no type and no path.
        def defaulted?(ctx, label)
          Array(ctx.site_cfg["defaults"]).any? do |d|
            next false unless d.is_a?(Hash) && d["values"].is_a?(Hash) && d["values"]["layout"]
            s = d["scope"].is_a?(Hash) ? d["scope"] : {}
            s["type"] == label || (s["type"].nil? && s["path"].to_s.empty?)
          end
        end
      end
    end
  end
end
