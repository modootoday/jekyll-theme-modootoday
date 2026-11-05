# frozen_string_literal: true

module Modootoday
  module Check
    module StructuredData
      # A single object under a property (offers, acceptedAnswer, hiringOrganization) gets the rules of a top-level
      # node, but what it breaks is a warning until 2.0 (adr:modootoday/20261103053804), so sites see it first.
      module Nested
        NOTE = "; fix it now (in a nested object this is an error from 2.0)"

        # Error-to-warning view of a ctx; everything below a nested object reports through it.
        Demoted = Struct.new(:ctx) do
          def errs = Sink.new(ctx.warns)
          def warns = ctx.warns
          def option?(opt) = ctx.option?(opt)
        end
        Sink = Struct.new(:warns) { def <<(msg) = warns << "#{msg}#{NOTE}" }

        module_function

        def call(ctx, f, n, path)
          StructuredData.node(ctx.is_a?(Demoted) ? ctx : Demoted.new(ctx), f, n, path)
        end
      end
    end
  end
end
