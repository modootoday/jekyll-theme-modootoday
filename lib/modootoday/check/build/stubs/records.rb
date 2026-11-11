# frozen_string_literal: true

require_relative "../../../stubs"

module Modootoday
  module Check
    # modootoday.records: every record has its page and every record page its record. The verdict is the plan of
    # modootoday-stubs --records --check, so the two never disagree; a record: naming no declared set is also an error.
    module Records
      HINT = "run modootoday-stubs SRC --records --write"

      module_function

      def call(ctx)
        sets = ctx.mtc.is_a?(Hash) ? ctx.mtc["records"] : nil
        return unless sets.is_a?(Hash) && !sets.empty?
        plan(ctx)
        ctx.mds.each do |f|
          src = File.read(f)
          next unless src.match?(/^record: /) && src.match?(Markdown::FM)
          rec = (Markdown.fm(src) rescue {})["record"]
          next if rec.nil?
          set = rec.to_s.split("/").first
          ctx.errs << "#{ctx.rel(f)}: record: #{rec} names no set in modootoday.records" unless sets.key?(set)
        end
      end

      def plan(ctx)
        source = Stubs::Source.new(ctx.src)
        Stubs::Plan.new(source, [:records]).changes.each do |c|
          why = { "missing" => "record page missing", "stale" => "record page out of date", "orphan" => "record page without a record" }.fetch(c.reason)
          ctx.errs << "#{c.path}: #{why}: #{HINT}"
        end
      rescue Stubs::ConfigError, Stubs::DataError => e
        ctx.errs << "modootoday.records: #{e.message}"
      end
    end
  end
end
