# frozen_string_literal: true

module Modootoday
  module Check
    # Slot contract (1.x): named, stable parts of a section's Markdown. Detection is structural and
    # mirrors what md-sections.html and the component scripts consume; markup does not change.
    module Slots
      DETECT = {
        "lead" => ->(m) { m.split(/\n\s*\n/).reject { |p| p.strip.empty? }.take_while { |p| p !~ /\A\s*([-*+]\s|\d+[.)]\s|###|```|~~~|>)/ }.count { |p| p =~ /\S/ && p !~ /\A\s*(\[[^\]]+\]\([^)]*\)\s*)+\z/ } },
        "items" => ->(m) { m.scan(/^([-*+]|\d+[.)])\s/).size },
        "panels" => ->(m) { m.scan(/^###(?: |$)/).size },
        "actions" => ->(m) { m.scan(/^(?:\[[^\]\n]+\]\([^)\n]*\)[ \t]*)+$/).size },
        "code" => ->(_m, raw) { n = 0; Markdown.strip_fences(raw) { n += 1 }; n },
        "figures" => ->(m) { m.scan(/^!\[[^\]\n]+\]\([^)\n]+\)/).size },
      }.freeze

      module_function

      def known?(name) = DETECT.key?(name)
      def names = DETECT.keys

      # The problem with one slot of one section, or nil.
      def count_problem(name, rule, md)
        m, raw = md || ["", ""]
        det = DETECT[name]
        n = det.arity == 2 ? det.call(m, raw) : det.call(m)
        rule = {} unless rule.is_a?(Hash)
        min = rule["min"].is_a?(Integer) ? rule["min"] : (rule["required"] == true ? 1 : nil)
        max = rule["max"].is_a?(Integer) ? rule["max"] : nil
        return "slot '#{name}' has #{n} item(s), needs at least #{min}" if min && n < min
        "slot '#{name}' has #{n} item(s), allows at most #{max}" if max && n > max
      end

      # slots: is a map (one form) or a list of maps (alternative forms; a section must satisfy one).
      def check_section(errs, file, i, c, slots, md)
        return if slots.nil?
        forms = (slots.is_a?(Array) ? slots : [slots]).select { |f| f.is_a?(Hash) }
        probs = forms.map { |form| form.select { |name, _| known?(name) }.filter_map { |name, rule| count_problem(name, rule, md) } }
        return if probs.empty? || probs.any?(&:empty?)
        if slots.is_a?(Array)
          errs << "#{file}: sections[#{i}] #{c}: matches none of #{forms.size} slot forms (#{probs.each_with_index.map { |p, k| "form #{k + 1}: #{p.join(', ')}" }.join('; ')})"
        else
          probs[0].each { |p| errs << "#{file}: sections[#{i}] #{c}: #{p}" }
        end
      end
    end
  end
end
