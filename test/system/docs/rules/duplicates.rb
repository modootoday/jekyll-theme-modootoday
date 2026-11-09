# frozen_string_literal: true

module DocsRules
  # R1: one canonical page per topic. No prose paragraph over MIN characters appears verbatim in two English pages
  # (examples, tables, lists and quotes are code-like and may repeat), and a page that names a topic of
  # docs/_data/topics.yml links the topic's canonical page.
  module Duplicates
    MIN = 200

    module_function

    def call(pages)
      out = Hash.new { |h, k| h[k] = [] }
      seen = Hash.new { |h, k| h[k] = [] }
      pages.docs.each do |p|
        paras = pages.body(p).split(/\n\s*\n/).map(&:strip).select { |x| x.size > MIN && !x.match?(/\A(\||-|\*|>|\d+\.|#|`[a-z]+:)/) }
        paras.uniq.each { |x| seen[x] << p.rel }
      end
      seen.each_value { |fs| out["R1 no repeated paragraph"] << "#{fs.join(" and ")}: the same paragraph" if fs.size > 1 }
      topics(pages, out)
      out
    end

    def topics(pages, out)
      file = "#{pages.tree.root}/_data/topics.yml"
      return unless File.file?(file)
      YAML.safe_load(File.read(file)).each do |t|
        canon = "/#{t["page"]}"
        pages.docs.each do |p|
          next if p.url == canon || !Modootoday::Markdown.strip_index_lists(pages.prose(p)).match?(/#{t["phrase"]}/i)
          next if pages.links(p).include?(canon)
          out["R1 a topic links its canonical page"] << "#{p.rel}: mentions #{t["topic"]} without a link to #{canon}"
        end
      end
    end
  end
end
