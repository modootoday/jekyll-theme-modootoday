# frozen_string_literal: true

module Modootoday
  module Check
    module Renderers
      module_function

      # Inline $…$ in prose (not $5 or "$ 5", not $$): rendered only with modootoday.math.inline: true.
      DOLLAR = /(?<![\\$\w])\$(?=[^\s$\d])[^$\n]*?[^\s\\$]\$(?![\w$])/

      # ```math fences and $$ blocks are the standard notation; inline $…$ renders only with inline: true.
      def notation(ctx)
        x = ctx.mtc.is_a?(Hash) ? ctx.mtc["math"] : nil
        return unless x.is_a?(Hash) && x["enabled"] == true && x["inline"] != true && ctx.respond_to?(:mds)
        ctx.mds.each do |f|
          n = inline_dollar(File.read(f))
          ctx.warns << "#{ctx.rel(f)}:#{n}: inline $…$ stays plain text on this site (modootoday.math.inline is false); use a ```math fence or a $$ block, or set inline: true" if n
        end
      end

      # Line number of the first inline $…$ outside code, or nil.
      def inline_dollar(text)
        fence = nil
        text.each_line.with_index(1) do |l, n|
          if l =~ /\A {0,3}(`{3,}|~{3,})/
            fence = fence ? (l.strip.start_with?(fence) ? nil : fence) : $1
            next
          end
          next if fence || l =~ /\A {4}|\A\t/
          return n if l.gsub(/`+[^`]*`+/, "").gsub("$$", "") =~ DOLLAR
        end
        nil
      end
    end
  end
end
