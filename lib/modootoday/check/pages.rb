# frozen_string_literal: true

require_relative "page_syntax"
require_relative "page_values"
require_relative "page_sections"
require_relative "a11y/content"

module Modootoday
  module Check
    # Per-page Markdown rules, run once per content page in this order.
    module Pages
      module_function

      def call(ctx)
        ctx.mds.each do |f|
          text = File.read(f)
          b = Markdown.body(text)
          code = Markdown.strip_code(b)
          h2 = PageSyntax.call(ctx, f, text, b, code)
          PageValues.call(ctx, f, b)
          PageSections.call(ctx, f, text, b, code, h2)
          A11yContent.call(ctx, f, Markdown.strip_comments(code))
        end
      end
    end
  end
end
