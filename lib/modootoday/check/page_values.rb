# frozen_string_literal: true

module Modootoday
  module Check
    # Rule 2: badge vocabularies in code spans (status:, tag:, since:, kbd:) and image alt text.
    module PageValues
      STATUS = %w[available partial planned].freeze

      module_function

      def call(ctx, f, b)
        errs, r = ctx.errs, ctx.rel(f)
        text = Markdown.strip_fences(b)
        text.scan(/`status:([^`\s]*)`/) do |(v)|
          errs << "#{r}: unregistered status value `status:#{v}` (allowed: #{STATUS.join('/')})" unless STATUS.include?(v)
        end
        text.scan(/`(tag|since):([^`]*)`/) do |(k, v)|
          errs << "#{r}: `#{k}:#{v}` badge value must be one token [A-Za-z0-9._-]" unless v =~ /\A[A-Za-z0-9._-]+\z/
        end
        text.scan(/`kbd:([^`]*)`/) do |(v)|
          errs << "#{r}: `kbd:#{v}` must be keys joined by '+' without spaces (e.g. `kbd:Ctrl+K`)" unless v =~ /\A[^\s+]+(\+[^\s+]+)*\z/
        end
        errs << "#{r}: image without alt text (![](...)); write ![description](...)" if text.gsub(/`[^`\n]*`/, "") =~ /!\[\s*\]\(/
      end
    end
  end
end
