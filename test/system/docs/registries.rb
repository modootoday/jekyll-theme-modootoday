# frozen_string_literal: true
# Docs follow the code registries (dev-only, adr:modootoday/20261109200230 R6): the Configuration key table and the
# checker's settings schema, the keys Liquid reads, the Public API layout table and _layouts/, and components.yml
# and the Components page. The Command line page is generated (script/readme-commands --check).
require "yaml"
require_relative "../../../lib/modootoday/check"
require_relative "../../../lib/modootoday/markdown"

root = File.expand_path("../../..", __dir__)
errs = []
read = ->(rel) { File.read(File.join(root, rel)) }
section = ->(src, head) { src[/^## #{Regexp.escape(head)}\n(.*?)(?=^## |\z)/m, 1].to_s }
codes = ->(text) { text.lines.grep(/\A\| /).map { |l| l.split("|")[1..-2].to_a }.flat_map { |c| c.first.to_s.scan(/`([^`]+)`/).flatten } }

schema = Modootoday::Check::Config::Schema.keys.keys.sort
{ "" => "Keys", ".ko" => "키", ".ja" => "キー" }.each do |suffix, head|
  rel = "docs/guides/configuration#{suffix}.md"
  table = codes.(section.(read.(rel), head)).uniq.sort
  (schema - table).each { |k| errs << "#{rel}: no row for modootoday.#{k}, which the checker registers" }
  (table - schema).each { |k| errs << "#{rel}: a row for modootoday.#{k}, which the checker does not register" }
end

liquid = Dir.glob("{_includes,_layouts}/**/*.html", base: root).flat_map { |f| read.(f).scan(/site\.modootoday(?:\.|\[["'])([a-z_]+)/).flatten }.uniq
(liquid - schema).each { |k| errs << "_includes/_layouts read modootoday.#{k}; register it in lib/modootoday/check/config/keys/" }

layouts = Dir.glob("_layouts/*.html", base: root).map { |f| File.basename(f, ".html") }.sort
{ "" => "Layouts", ".ko" => "레이아웃", ".ja" => "レイアウト" }.each do |suffix, head|
  rel = "docs/reference/api#{suffix}.md"
  rows = section.(read.(rel), head).lines.grep(/\A\| /).flat_map { |l| l.split("|")[2].to_s.scan(/`([^`]+)`/).flatten }.sort
  (layouts - rows).each { |l| errs << "#{rel}: layout #{l} is in _layouts/ but not in the Layouts table" }
  (rows - layouts).each { |l| errs << "#{rel}: layout #{l} is in the Layouts table but not in _layouts/" }
  rows.tally.select { |_, n| n > 1 }.each_key { |l| errs << "#{rel}: layout #{l} is listed twice" }
end

registry = YAML.safe_load(read.("docs/_data/components.yml")) || {}
sections = Array(Modootoday::Markdown.fm(read.("docs/components/index.md"))["sections"]).map { |s| s.is_a?(Hash) ? (s["c"] || s["name"]) : s }
(registry.keys - sections).each { |c| errs << "docs/components/index.md: no section for #{c} of docs/_data/components.yml" }

puts errs.empty? ? "docs registries: OK" : errs
exit(errs.empty? ? 0 : 1)
