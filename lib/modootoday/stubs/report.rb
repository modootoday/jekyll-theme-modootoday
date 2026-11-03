# frozen_string_literal: true

module Modootoday
  module Stubs
    # Prints a plan: one line per change and a summary, or the whole plan as JSON.
    module Report
      module_function

      def json(plan, mode)
        rows = plan.changes.map { |c| { "path" => c.path, "action" => c.action, "reason" => c.reason } }
        puts JSON.pretty_generate("mode" => mode, "kinds" => plan.kinds.map(&:to_s), "changes" => rows)
      end

      def text(plan, mode, quiet:)
        out = mode == "check" ? $stderr : $stdout
        plan.changes.each { |c| out.puts "#{c.action} #{c.path} (#{c.reason})" } unless quiet && mode != "check"
        return if quiet
        out.puts summary(plan.changes, mode)
      end

      def summary(changes, mode)
        n = changes.size
        return "modootoday-stubs: up to date" if n.zero?
        return "modootoday-stubs: #{n} change(s) planned; add --write to apply them" if mode == "preview"
        return "modootoday-stubs: #{n} stub(s) out of date; run modootoday-stubs with --write" if mode == "check"
        gone = changes.count { |c| c.content.nil? }
        "modootoday-stubs: #{n - gone} written, #{gone} removed"
      end
    end
  end
end
