# frozen_string_literal: true

module Modootoday
  module Check
    module Native
      # jekyll-default-layout (on in GitHub Pages) gives a collection document without a layout the layout named like its
      # collection. When that is a theme list layout, the document draws as its detail page (mt_self_detail, a warning);
      # a layout without one (blog, feed, search) cannot show one document (an error). defaults for the type end both.
      module Collections
        THEME = File.expand_path("../../../../_layouts", __dir__)

        module_function

        def call(ctx)
          cols = ctx.site_cfg["collections"]
          return unless cols.is_a?(Hash)
          cols.each do |label, c|
            next unless c.is_a?(Hash) && c["output"] == true && File.file?("#{THEME}/#{label}.html")
            next if File.file?("#{ctx.src}/_layouts/#{label}.html") || defaulted?(ctx, label)
            bare = docs(ctx, label).reject { |_, fm| fm.key?("layout") }
            report(ctx, label, bare.size) unless bare.empty?
          end
        end

        def report(ctx, label, n)
          detail = Markdown.fm(File.read("#{THEME}/#{label}.html"))["mt_self_detail"]
          fix = "set defaults: [{scope: {type: #{label}}, values: {layout: #{detail || '<a layout>'}}}] in _config.yml"
          where = "_config.yml: collections.#{label}: #{n} document(s) without a layout get the #{label} layout from jekyll-default-layout"
          return ctx.warns << "#{where}, which draws each as a #{detail} page; #{fix}" if detail
          ctx.errs << "#{where}, which cannot show one document; #{fix}"
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
