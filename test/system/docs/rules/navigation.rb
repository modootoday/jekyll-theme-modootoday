# frozen_string_literal: true

module DocsRules
  # R7: sidebar groups of 12 entries or fewer (a warning from 11), no group directory with only an index, no orphan
  # page, and sample-site pages out of the docs navigation.
  module Navigation
    WARN_AT = 11

    module_function

    def call(pages)
      out = Hash.new { |h, k| h[k] = [] }
      t = pages.tree
      t.langs.each do |lang|
        t.sections.map { |s| s["id"] }.each do |id|
          ([id] + t.entries(id, lang).select(&:group_index?).map(&:dir)).each do |g|
            n = t.entries(g, lang).size
            out["R7 group size warning"] << "#{lang} #{g}: #{n} sidebar entries (warning from #{WARN_AT}, limit 12)" if n >= WARN_AT
          end
        end
      end
      pages.docs.select(&:group_index?).each do |idx|
        kids = pages.docs.reject { |p| p.equal?(idx) }.select { |p| p.key.start_with?("#{idx.dir}/") }
        out["R7 no index-only group"] << "#{idx.dir}/: a group directory with only an index" if kids.empty?
      end
      orphans(pages, out)
      pages.all.select { |p| pages.sample?(p) }.each do |p|
        out["R7 sample pages out of the docs nav"] << "#{p.rel}: sample-site page in the docs navigation" if p.fm["nav_section"] && p.fm["nav_section"] != "sample"
      end
      out
    end

    # A page is reachable when the sidebar lists it or a reachable page links it; error and redirect pages are exempt.
    def orphans(pages, out)
      t = pages.tree
      listed = t.langs.flat_map { |l| t.sections.flat_map { |s| nav_urls(t, s["id"], l) } }.uniq
      seen = listed + pages.all.select { |p| p.key == "index.md" }.map(&:url)
      queue = seen.dup
      until queue.empty?
        page = pages.by_url[queue.shift] or next
        pages.links(page).each { |u| queue << u unless seen.include?(u) || !(seen << u) }
      end
      pages.tree.langs.each do |lang|
        pages.docs(lang).each do |p|
          next if seen.include?(p.url) || p.fm["layout"] == "error" || p.key == "404.md"
          out["R7 no orphan page"] << "#{p.rel}: neither in the sidebar nor linked from a page that is"
        end
      end
    end

    def nav_urls(t, dir, lang)
      idx = t.index_of(dir, lang)
      ([idx&.url] + t.entries(dir, lang).flat_map { |p| p.group_index? ? nav_urls(t, p.dir, lang) : [p.url] }).compact
    end
  end
end
