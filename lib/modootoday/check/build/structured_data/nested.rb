# frozen_string_literal: true

module Modootoday
  module Check
    module StructuredData
      # A single object under a property (offers, acceptedAnswer, hiringOrganization) gets the rules of a top-level
      # node, but what it breaks is a warning until 2.0 (adr:modootoday/20261103053804), so sites see it first.
      module Nested
        NOTE = " (a warning in a nested object, an error in the next major version)"
        # The front matter that writes an offer, so the warning points at the fix rather than the JSON-LD path.
        OFFERS = "; set the offer in front matter: schema: {offers: {type: Offer, price: ..., priceCurrency: ...}} (tickets: alone gives only its url)"

        # Error-to-warning view of a ctx; everything below a nested object reports through it.
        Demoted = Struct.new(:ctx, :hint) do
          def errs = Sink.new(ctx.warns, hint)
          def warns = ctx.warns
          def option?(opt) = ctx.option?(opt)
        end
        Sink = Struct.new(:warns, :hint) { def <<(msg) = warns << "#{msg}#{hint}#{NOTE}" }

        module_function

        def call(ctx, f, n, path)
          StructuredData.node(ctx.is_a?(Demoted) ? ctx : Demoted.new(ctx, path.to_s.match?(/(\A|\.)offers\z/) ? OFFERS : ""), f, n, path)
        end
      end
    end
  end
end
