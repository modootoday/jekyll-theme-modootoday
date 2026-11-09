# frozen_string_literal: true
# Component order (dev-only, adr:modootoday/20261109141344): docs/_data/component_groups.yml names every component's
# group, and the components index and kitchen sinks list their sections in that order, in every language, with a
# group heading (a `group-<id>` section titled in the page's language) before each group.
require "yaml"
require_relative "../../../lib/modootoday/markdown"
require_relative "../../../lib/modootoday/check/config/site_config"
require_relative "../../support/asset_registry"

root = File.expand_path("../../..", __dir__)
FILE = "docs/_data/component_groups.yml"
groups = YAML.safe_load(File.read("#{root}/#{FILE}")) || []
errs = []
ids = groups.flat_map { |g| Array(g["components"]) }
group_of = groups.each_with_index.flat_map { |g, i| Array(g["components"]).map { |c| [c, i] } }.to_h

groups.each do |g|
  list = Array(g["components"])
  errs << "#{FILE}: a group needs id, title.en and components" unless g["id"] && g.dig("title", "en") && !list.empty?
  errs << "#{FILE}: #{g["id"]}: components are not A-Z by id" unless list == list.sort
end
ids.tally.select { |_, n| n > 1 }.each_key { |c| errs << "#{FILE}: #{c} is in more than one group" }
known = Modootoday::Check::SiteConfig::COMPONENTS
(known - ids).each { |c| errs << "#{FILE}: component #{c} is in no group" }

# A c: section names its component (features is the card section, by the registry); any other section is named
# after its component id or <id>-<variant>.
by_c = AssetRegistry.rows("_mta_rows").select { |r| r.kind == "section" }.to_h { |r| [r.triggers.first, r.name] }
reg = YAML.safe_load(File.read("#{root}/docs/_data/components.yml")) || {}
errs << "docs/_data/components.yml: keys are not A-Z" unless reg.keys == reg.keys.sort
errs << "the checker's COMPONENTS are not A-Z" unless known == known.sort
reg.each_key { |c| errs << "docs/_data/components.yml: #{c} is in no group of #{FILE}" unless group_of.key?(by_c.fetch(c, c)) }
component = lambda do |s|
  next by_c.fetch(s["c"], s["c"]) if s["c"]
  ids.select { |i| s["name"] == i || s["name"].to_s.start_with?("#{i}-") }.max_by(&:size)
end

topics = []
Dir.glob("#{root}/docs/components/{index,kitchen-sink}*.md").sort.each do |f|
  rf = f.delete_prefix("#{root}/")
  src = File.read(f)
  fm = Modootoday::Markdown.fm(src) || {}
  lang = rf[/\.([a-z]{2}(?:-[A-Za-z]+)?)\.md\z/, 1] || fm["lang"] || "en"
  heads = groups.all? { |g| g.dig("title", lang) }
  titles = src.split(/^## /)[1..].to_a.map { |b| b.lines.first.strip }
  last, seen = [-1, ""], []
  Array(fm["sections"]).each_with_index do |s, i|
    s = s.is_a?(Hash) ? s : { "name" => s }
    if (gid = s["name"].to_s[/\Agroup-(.+)\z/, 1])
      g = groups.index { |x| x["id"] == gid }
      next errs << "#{rf}: sections[#{i}] #{s["name"]}: unknown group" unless g
      errs << "#{rf}: #{s["name"]} is titled '#{titles[i]}', not '#{groups[g].dig("title", lang)}'" if heads && titles[i] != groups[g].dig("title", lang)
      errs << "#{rf}: #{s["name"]} is out of order" if g < last[0] || seen.include?(g)
      seen << g
      last = [g, ""]
      next
    end
    c = component.call(s)
    next errs << "#{rf}: sections[#{i}] #{s["name"]}: no component in #{FILE}" unless c && group_of.key?(c)
    topics << c unless known.include?(c)
    key = [group_of[c], c]
    errs << "#{rf}: #{s["name"]} (#{c}) comes after #{last[1]}; the order is #{FILE}, A-Z by id inside a group" if (key <=> last) == -1
    errs << "#{rf}: #{s["name"]} (#{c}) has no group-#{groups[key[0]]["id"]} heading before it" if heads && !seen.include?(key[0])
    last = key
  end
end
(ids - known - topics).each { |c| errs << "#{FILE}: #{c} is neither a component nor a section of the components pages" }

puts errs.empty? ? "component order: OK" : errs
exit(errs.empty? ? 0 : 1)
