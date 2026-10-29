# frozen_string_literal: true
# Docs structure (dev-only): fails when docs/ drifts from the information architecture in
# .spec/adr (sections from docs/_data/sections.yml, one source of truth in front matter).
require_relative "../../script/docs/tree"
require_relative "../../script/docs/outputs"

LIMIT_FILES = 12   # authored files per directory (generated .md.txt twins excluded)
LIMIT_ENTRIES = 12 # sidebar entries per group
SAMPLE_DIRS = %w[blog news authors].freeze
ROOT_PAGES = %w[index.md 404.md tags.md categories.md].freeze
BANNED = [/^since:/, /\bdeprecat/i, /\b2\.0\b/, /\bfrozen\b/i, /\.spec\.local/].freeze

tree = DocsIndex::Tree.new(File.expand_path("../../docs", __dir__))
out = DocsIndex::Outputs.new(tree)
ids = tree.sections.map { |s| s["id"] }
errs = []
rel = ->(p) { p.delete_prefix("#{tree.root}/") }

stale = out.files.reject { |path, body| File.exist?(path) && File.read(path) == body }.keys + out.orphan_twins
stale.each { |p| errs << "#{rel[p]}: out of date; run ruby script/docs-index" }

tree.pages.each do |p|
  next if p.rel.include?("_posts/")
  next if SAMPLE_DIRS.include?(p.key.split("/").first) # live sample sites (blog, news, authors) own their layouts; not docs
  f = p.rel
  if p.dir == "."
    errs << "#{f}: pages live in a section directory (#{ids.join(', ')})" unless ROOT_PAGES.include?(p.key)
  else
    errs << "#{f}: unknown section `#{p.section}` (add it to docs/_data/sections.yml)" unless ids.include?(p.section)
    errs << "#{f}: too deep; at most <section>/<group>/<page>.md" if p.key.count("/") > 2
    errs << "#{f}: a group directory needs an index.md" if p.group && !File.exist?("#{File.dirname(p.path)}/index.md")
  end
  %w[title description].each { |k| errs << "#{f}: front matter needs `#{k}:`" if p.fm[k].to_s.strip.empty? }
  errs << "#{f}: front matter needs an integer `nav_order:` (or `nav_exclude: true`)" if p.dir != "." && !p.fm["nav_exclude"] && !p.order.is_a?(Integer)
  src = File.read(p.path)
  BANNED.each { |re| errs << "#{f}: user docs must not contain #{re.source}" if src.match?(re) && !p.key.start_with?("reference/changelog") }
  if p.lang != tree.default_lang && tree.pages.none? { |e| e.lang == tree.default_lang && e.key == p.key }
    errs << "#{f}: no English page docs/#{p.key} (English is canonical)"
  end
end

Dir.glob("#{tree.root}/**/").reject { |d| rel[d].start_with?("_", "assets", "vendor") }.each do |d|
  n = Dir.children(d).count { |c| File.file?("#{d}#{c}") && !c.end_with?(".md.txt") }
  errs << "#{rel[d]}: #{n} authored files (limit #{LIMIT_FILES}); split into groups" if n > LIMIT_FILES
end

tree.langs.each do |lang|
  ids.each do |id|
    groups = [id] + tree.entries(id, lang).select(&:group_index?).map(&:dir)
    groups.each do |g|
      n = tree.entries(g, lang).size
      errs << "#{lang} #{g}: #{n} sidebar entries (limit #{LIMIT_ENTRIES}); add a group" if n > LIMIT_ENTRIES
    end
  end
end

puts errs.empty? ? "docs structure: OK" : errs
exit(errs.empty? ? 0 : 1)
