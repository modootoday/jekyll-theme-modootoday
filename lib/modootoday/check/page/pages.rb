# frozen_string_literal: true

require_relative "page_syntax"
require_relative "page_values"
require_relative "component_rules"
require_relative "page_sections"
require_relative "hero_script"
require_relative "filter"
require_relative "chart"
require_relative "widget"
require_relative "a11y/content"
require_relative "a11y/new_window"
require_relative "a11y/illustration"
require_relative "figures/diagrams"
require_relative "figures/freshness"
require_relative "figures/math_static"

module Modootoday
  module Check
    # Per-page Markdown rules, run once per content page in this order.
    module Pages
      module_function

      def call(ctx)
        unchecked(ctx)
        ctx.mds.each do |f|
          text = File.read(f)
          next licence(ctx, f) if licence?(f, text)
          b = Markdown.body(text)
          code = Markdown.strip_code(b)
          h2 = PageSyntax.call(ctx, f, text, b, code)
          PageValues.call(ctx, f, b)
          ComponentRules.inline(ctx, ctx.rel(f), b)
          PageSections.call(ctx, f, text, b, code, h2)
          Filter.call(ctx, f, text, b, code)
          Chart.call(ctx, f, text, b, code)
          Widget.call(ctx, f, text, b, code)
          A11yContent.call(ctx, f, Markdown.strip_comments(code))
          NewWindow.call(ctx, f, text, Markdown.strip_comments(code))
          FigureDiagrams.call(ctx, f, text)
          FigureFreshness.call(ctx, f, text)
          MathStatic.call(ctx, f, text)
        end
      end

      LICENCE = /\A(?:.+\.)?(?:LICEN[CS]E|COPYING|NOTICE)\z/i

      # A vendored licence (chart.LICENSE.md) without front matter is no page of the site's, but the Pages builder
      # renders Markdown without front matter, so the page rules would only misreport it.
      def licence?(f, text) = File.basename(f, ".md").match?(LICENCE) && !(text.start_with?("---\n") && text =~ Markdown::FM)

      def licence(ctx, f)
        txt = ctx.rel(f).delete_suffix(".md") + ".txt"
        ctx.errs << "#{ctx.rel(f)}: a licence file saved as Markdown becomes a page on GitHub Pages; save it as #{txt}, or list it in exclude:"
      end

      # Jekyll also renders .markdown, .mkd and .mkdn (jekyll new writes about.markdown); the rules read only .md.
      def unchecked(ctx)
        Dir.glob("#{ctx.src}/**/*.{markdown,mkd,mkdn}").reject { |f| ctx.skipped?(f) }.sort.each do |f|
          ctx.warns << "#{ctx.rel(f)}: not checked (the rules read .md pages); rename it to .md"
        end
      end
    end
  end
end
