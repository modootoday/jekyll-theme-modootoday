# frozen_string_literal: true
# Kitchen-sink coverage (dev-only): every component registered in docs/_data/components.yml and every
# alert type and status value must appear in docs/components/kitchen-sink.md (and each translation).
require "yaml"
root = File.expand_path("../..", __dir__)
reg = YAML.safe_load(File.read("#{root}/docs/_data/components.yml")) || {}
errs = []
Dir.glob("#{root}/docs/{,*/}components/kitchen-sink.md").each do |f|
  src = File.read(f)
  fm = YAML.safe_load(src[/\A---\n(.*?)\n---\n/m, 1].to_s) || {}
  used = Array(fm["sections"]).map { |s| s.is_a?(Hash) ? s["c"] : nil }.compact
  reg.each_key { |c| errs << "#{f}: component `#{c}` not shown" unless used.include?(c) }
  %w[NOTE TIP IMPORTANT WARNING CAUTION].each { |t| errs << "#{f}: alert #{t} missing" unless src.include?("> [!#{t}]") }
  %w[tag: kbd:].each { |p| errs << "#{f}: #{p} badge missing" unless src.match?(/`#{p}[A-Za-z0-9._+\/-]+`/) }
  errs << "#{f}: figure (image + *caption*) missing" unless src.match?(/^!\[[^\]]+\]\([^)]+\)\n\n\*[^*\n]+\*$/)
  errs << "#{f}: .mt-flat-list demo (visual: flat-list) missing" unless src.include?("visual: flat-list")
  %w[available partial planned].each { |v| errs << "#{f}: status:#{v} missing" unless src.include?("`status:#{v}`") }
end
errs << "no kitchen-sink page" if Dir.glob("#{root}/docs/components/kitchen-sink.md").empty?
# Components pages (layout: examples): every registered component and every inline component has at least one
# example section (source printed by the layout + live result), and the built page pairs each one.
INLINE = { "alert" => /^> \[!NOTE\]/, "badge" => /`status:available`/, "kbd" => /`kbd:[^`]+`/,
           "figure" => /^!\[[^\]]+\]\([^)]+\)\n\n\*[^*\n]+\*$/, "table" => /^\|.*\|\n\|[-:| ]+\|$/, "code" => /^```\w+$/ }.freeze
site = ARGV[0] || "#{root}/docs/_site"
Dir.glob("#{root}/docs/{,*/}components/index.md").reject { |f| f.include?("/_site/") }.each do |f|
  src = File.read(f)
  fm = YAML.safe_load(src[/\A---\n(.*?)\n---\n/m, 1].to_s) || {}
  next errs << "#{f}: must use layout: examples" unless fm["layout"] == "examples"
  ex = Array(fm["examples"])
  secs = Array(fm["sections"]).map { |s| s.is_a?(Hash) ? s : { "name" => s } }
  names = secs.map { |s| s["name"] }
  ex.each { |n| errs << "#{f}: example `#{n}` is not a section name" unless names.include?(n) }
  bodies = src.split(/^## /)[1..].to_a
  shown = secs.each_with_index.select { |s, _| ex.include?(s["name"]) }
  reg.each_key { |c| errs << "#{f}: component `#{c}` has no example" unless shown.any? { |s, _| s["c"] == c } }
  ex_src = shown.map { |_, i| bodies[i].to_s }.join("\n")
  INLINE.each { |k, re| errs << "#{f}: #{k} has no example" unless ex_src.match?(re) }
  shown.each do |s, i|
    parts = bodies[i].to_s.split(/\n\n/, 3)
    errs << "#{f}: example `#{s["name"]}` needs a one-paragraph description and then the example" if parts.size < 3 || parts[2].strip.empty?
  end
  rel = f.delete_prefix("#{root}/docs/").delete_suffix("index.md")
  html = "#{site}/#{rel}index.html"
  next unless File.exist?(html)
  h = File.read(html)
  ex.each do |n|
    sec = h[/data-section="#{Regexp.escape(n)}".*?<\/section>/m].to_s
    errs << "#{html}: example `#{n}` lacks a source block" unless sec.include?('docs-ex-source') && sec.include?("<pre")
    errs << "#{html}: example `#{n}` lacks the rendered result" unless sec.include?('docs-ex-result')
  end
end
puts errs.empty? ? "kitchen-sink coverage: OK" : errs
exit(errs.empty? ? 0 : 1)
