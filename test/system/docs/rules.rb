# frozen_string_literal: true
# Docs consistency rules (dev-only, adr:modootoday/20261109200230), read from the sources with no build.
# A rule in BLOCKING fails the run; the others are reported until the pages meet them. Usage: ruby test/system/docs/rules.rb
require_relative "rules/pages"
require_relative "rules/front_matter"
require_relative "rules/versions"
require_relative "rules/navigation"
require_relative "rules/links"
require_relative "rules/duplicates"
require_relative "rules/callouts"

BLOCKING = [
  "R1 no repeated paragraph", "R1 a topic links its canonical page", "R3 H1 is the title", "R3 description repeats the title",
  "R3 nav_title shortens the title", "R3 unique nav_order", "R3 demo pages set twin", "R5 no version in a heading",
  "R5 no past version in the body", "R7 no orphan page", "R7 sample pages out of the docs nav", "R8 relative links",
  "R8 guides and recipes link a related page", "R7 no index-only group", "Callouts: known alert type"
].freeze

pages = DocsRules::Pages.new(File.expand_path("../../../docs", __dir__))
found = [DocsRules::FrontMatter, DocsRules::Versions, DocsRules::Navigation, DocsRules::Links, DocsRules::Duplicates, DocsRules::Callouts]
        .map { |r| r.call(pages) }.reduce({}) { |a, h| a.merge(h) { |_, x, y| x + y } }
fail_rules = found.select { |name, msgs| BLOCKING.include?(name) && !msgs.empty? }
found.sort.each do |name, msgs|
  next if msgs.empty?
  puts "#{BLOCKING.include?(name) ? "error" : "report"}: #{name} (#{msgs.size})"
  msgs.first(ENV["ALL"] ? msgs.size : 20).each { |m| puts "  #{m}" }
end
puts fail_rules.empty? ? "docs rules: OK" : "docs rules: #{fail_rules.size} blocking rule(s) fail"
exit(fail_rules.empty? ? 0 : 1)
