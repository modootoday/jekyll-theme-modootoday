# frozen_string_literal: true

module Modootoday
  module Check
    # .mt-illustration (WCAG 1.1.1): a drawn scene is one image to assistive technology, so it must be
    # <figure role="img"> with a non-empty aria-label; its children (and any .mt-illustration-tag) are not read.
    module Illustration
      OPEN = /<([a-z][a-z0-9]*)\b[^>]*\bclass="[^"]*\bmt-illustration\b(?!-)[^"]*"[^>]*>/i

      module_function

      def call(ctx)
        Dir.glob("#{ctx.site}/**/*.html").each do |f|
          File.read(f).gsub(%r{<pre\b.*?</pre>}m, "").scan(OPEN) do
            tag, el = Regexp.last_match(1), Regexp.last_match(0)
            label = el[/\baria-label="([^"]*)"/, 1].to_s.strip
            next if tag.casecmp?("figure") && el =~ /\brole="img"/ && !label.empty?
            ctx.errs << "#{f}: .mt-illustration must be <figure role=\"img\" aria-label=\"…\"> with a non-empty label (got #{el[0, 120]})"
          end
        end
      end
    end
  end
end
