# frozen_string_literal: true
# Component examples in a built docs site, checked in the HTML (the browser half is test/system/audit/features/components.mjs).
# Usage: ruby test/system/docs/examples.rb SITE_DIR
# Fails on Markdown or Liquid that reached the page as text, an example whose source or front matter block is empty,
# hidden or not valid YAML equal to the page's sections: entry, and a list form of a c: section with no rule in its sheet.
require "nokogiri"
require "yaml"

site = File.expand_path(ARGV[0] || "docs/_site")
docs = File.expand_path("../../../docs", __dir__)
PAGES = { "components/index" => "components/", "components/kitchen-sink" => "components/kitchen-sink/",
          "components/kitchen-sink-rtl" => "components/kitchen-sink-rtl/", "recipes/figures/charts" => "recipes/figures/charts/",
          "recipes/figures/widgets" => "recipes/figures/widgets/", "recipes/figures/math-diagrams" => "recipes/figures/math-diagrams/" }.freeze
LEAKS = { /\{%|%\}|\{\{|\}\}/ => "Liquid", /\{:[\s.#\w]/ => "a kramdown attribute list", /\*\*\S/ => "literal **",
          /<\/?(div|span|p|details|summary)\b|markdown="?1/ => "raw HTML", /\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/i => "an alert marker" }.freeze
SKIP = "pre, code, script, style, template, textarea, kbd"
css = Dir[File.join(site, "assets/css/**/*.css")].map { |f| File.read(f) }.join("\n").gsub(/\s*>\s*/, ">")
errs = []

PAGES.each do |src, url|
  ["", "ko", "ja"].each do |lang|
    file = File.join(docs, "#{src}#{lang.empty? ? '' : ".#{lang}"}.md")
    html = File.join(site, lang, url, "index.html")
    next unless File.exist?(file) && File.exist?(html)

    entries = (YAML.safe_load(File.read(file)[/\A---\n(.*?)\n---/m, 1].to_s) || {})["sections"] || []
    byname = entries.to_h { |e| [e.is_a?(Hash) ? e["name"] : e, e] }
    doc = Nokogiri::HTML(File.read(html))
    at = "/#{lang.empty? ? '' : "#{lang}/"}#{url}"
    doc.css("main section[data-section]").each do |sec|
      name = sec["data-section"]
      sec.xpath(".//text()").each do |t|
        next if t.ancestors.any? { |a| a.element? && (a.matches?(SKIP) || a["class"].to_s.include?("docs-ex-code")) }
        LEAKS.each { |re, what| errs << "#{at} #{name}: #{what} shown as text: #{t.text.strip[0, 60].inspect}" if t.text =~ re }
      end
      code = sec.at_css(".docs-ex-code")
      if code
        errs << "#{at} #{name}: the example source sits inside a widget fallback or a hidden element" if code.ancestors(".mt-widget-fallback, [hidden]").any?
        source = code.at_css(".docs-ex-source + div pre")
        errs << "#{at} #{name}: the example source is empty" if source.nil? || source.text.strip.empty?
        fm = code.at_css(".docs-ex-fm + div pre")
        if fm
          shown = begin
            YAML.safe_load(fm.text)
          rescue Psych::Exception => e
            "#{e.class}: #{e.message[0, 60]}"
          end
          want = { "sections" => [byname[name]] }
          errs << "#{at} #{name}: the front matter shown is not the page's entry: #{fm.text.lines.last.strip}" unless shown == want
          errs << "#{at} #{name}: the front matter block ends in a blank line" if fm.text.end_with?("\n\n")
        end
      end
      c = sec["data-c"]
      sec.element_children.select { |n| %w[ol ul].include?(n.name) }.each do |list|
        next if list["class"].to_s.include?("mt-") || list.css("> li").all? { |li| li["class"].to_s.include?("mt-") }
        errs << "#{at} #{name}: c: #{c} has a #{list.name} form but its sheet has no .mt-c-#{c}>#{list.name} rule" if c && !css.include?(".mt-c-#{c}>#{list.name}")
      end
    end
  end
end
errs.uniq.each { |e| puts "FAIL #{e}" }
puts "component examples: #{errs.uniq.size} failures"
exit(errs.empty? ? 0 : 1)
