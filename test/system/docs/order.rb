# frozen_string_literal: true
# Component order (dev-only, adr:modootoday/20261114090712): docs/_data/component_groups.yml names every component's
# group and English title, A-Z by title inside a group. The English components index and kitchen sink list their
# sections in the group order, A-Z by section heading inside a group, after a `group-<id>` heading section; every
# other language keeps the English order (a section is placed by the English heading of the same section name).
require "yaml"
require_relative "../../../lib/modootoday/markdown"
require_relative "../../../lib/modootoday/check/config/site_config"
require_relative "../../support/asset_registry"

root = File.expand_path("../../..", __dir__)
FILE = "docs/_data/component_groups.yml"
INDEX = "docs/components/index.md"
SINK = "docs/components/kitchen-sink.md"
groups = YAML.safe_load(File.read("#{root}/#{FILE}")) || []
errs = []
members = ->(g) { g["components"].is_a?(Hash) ? g["components"] : {} }
title_of = groups.map(&members).reduce({}, :merge)
ids = groups.flat_map { |g| members.call(g).keys }
group_of = groups.each_with_index.flat_map { |g, i| members.call(g).keys.map { |c| [c, i] } }.to_h
sort_key = ->(t) { t.to_s.downcase }

groups.each do |g|
  list = members.call(g)
  next errs << "#{FILE}: a group needs id, title.en and components (id: English title)" unless g["id"] && g.dig("title", "en") && !list.empty?
  keys = list.values.map(&sort_key)
  errs << "#{FILE}: #{g["id"]}: components are not A-Z by English title" unless keys == keys.sort
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

pages = Dir.glob("#{root}/docs/components/{index,kitchen-sink}*.md").sort.to_h do |f|
  src = File.read(f)
  fm = Modootoday::Markdown.fm(src) || {}
  secs = Array(fm["sections"]).map { |s| s.is_a?(Hash) ? s : { "name" => s } }
  [f.delete_prefix("#{root}/"), [fm, secs, src.split(/^## /)[1..].to_a.map { |b| b.lines.first.strip }]]
end
headings = ->(rf) { _, secs, titles = pages[rf]; secs.each_with_index.to_h { |s, i| [s["name"].to_s, titles[i]] } }
# The English heading of a section name; on the kitchen-sink pages the kitchen sink's own heading wins.
english = ->(rf) { rf.include?("kitchen-sink") ? headings.call(INDEX).merge(headings.call(SINK)) : headings.call(SINK).merge(headings.call(INDEX)) }

first_title = {}
pages[INDEX][1].each_with_index { |s, i| (c = component.call(s)) && first_title[c] ||= pages[INDEX][2][i] }
first_title.each do |c, t|
  errs << "#{FILE}: #{c} is titled '#{title_of[c]}', but its first section on #{INDEX} is '#{t}'" if title_of.key?(c) && title_of[c] != t
end

topics = []
pages.each do |rf, (fm, secs, titles)|
  lang = rf[/\.([a-z]{2}(?:-[A-Za-z]+)?)\.md\z/, 1] || fm["lang"] || "en"
  heads = groups.all? { |g| g.dig("title", lang) }
  en = english.call(rf)
  last, seen = [-1, ""], []
  secs.each_with_index do |s, i|
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
    title = lang == "en" ? titles[i] : en.fetch(s["name"].to_s, title_of[c])
    key = [group_of[c], sort_key.call(title)]
    if (key <=> last) == -1
      errs << "#{rf}: #{s["name"]} ('#{title}') comes before '#{last[1]}' in #{FILE} order, A-Z by English title inside a group"
    end
    errs << "#{rf}: #{s["name"]} (#{c}) has no group-#{groups[key[0]]["id"]} heading before it" if heads && !seen.include?(key[0])
    last = key
  end
end
(ids - known - topics).each { |c| errs << "#{FILE}: #{c} is neither a component nor a section of the components pages" }

puts errs.empty? ? "component order: OK" : errs
exit(errs.empty? ? 0 : 1)
