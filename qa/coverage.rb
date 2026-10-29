# frozen_string_literal: true
# Kitchen-sink coverage (dev-only): every component registered in docs/_data/components.yml and every
# alert type and status value must appear in docs/components/kitchen-sink.md (and each translation).
require "yaml"
root = File.expand_path("..", __dir__)
reg = YAML.safe_load(File.read("#{root}/docs/_data/components.yml")) || {}
errs = []
Dir.glob("#{root}/docs/{,*/}components/kitchen-sink.md").each do |f|
  src = File.read(f)
  fm = YAML.safe_load(src[/\A---\n(.*?)\n---\n/m, 1].to_s) || {}
  used = Array(fm["sections"]).map { |s| s.is_a?(Hash) ? s["c"] : nil }.compact
  reg.each_key { |c| errs << "#{f}: component `#{c}` not shown" unless used.include?(c) }
  %w[NOTE TIP IMPORTANT WARNING CAUTION].each { |t| errs << "#{f}: alert #{t} missing" unless src.include?("> [!#{t}]") }
  %w[tag: since: kbd:].each { |p| errs << "#{f}: #{p} badge missing" unless src.match?(/`#{p}[A-Za-z0-9._+\/-]+`/) }
  errs << "#{f}: figure (image + *caption*) missing" unless src.match?(/^!\[[^\]]+\]\([^)]+\)\n\n\*[^*\n]+\*$/)
  %w[available partial planned].each { |v| errs << "#{f}: status:#{v} missing" unless src.include?("`status:#{v}`") }
end
errs << "no kitchen-sink page" if Dir.glob("#{root}/docs/components/kitchen-sink.md").empty?
puts errs.empty? ? "kitchen-sink coverage: OK" : errs
exit(errs.empty? ? 0 : 1)
