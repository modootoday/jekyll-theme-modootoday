# frozen_string_literal: true

module DocsRules
  # R3: the front matter contract of every docs page, in every language for the keys a translation carries.
  module FrontMatter
    ORDER = %w[lang permalink source_rev moved_from nav_order nav_exclude nav_section nav_title title description].freeze
    DESCRIPTION = (70..160)

    module_function

    def call(pages)
      out = Hash.new { |h, k| h[k] = [] }
      pages.tree.langs.each do |lang|
        pages.docs(lang).each { |p| check(p, pages, out) }
      end
      unique_orders(pages, out)
      out
    end

    # A layout demo's H1 and nav label are sample content, a home page's H1 is its hero headline, and a page
    # written in another language than its file's (the right-to-left samples) keeps an English title for the nav.
    def check(p, pages, out)
      fm, f = p.fm, p.rel
      h1 = pages.body(p)[/^# (.+)$/, 1]
      plain = !demo?(p) && p.key != "index.md" && [nil, p.lang].include?(fm["lang"])
      out["R3 H1 is the title"] << "#{f}: H1 '#{h1}' is not the title '#{fm["title"]}'" if plain && h1 && h1.strip != fm["title"].to_s.strip
      d = fm["description"].to_s
      out["R3 description length"] << "#{f}: description is #{d.size} characters (#{DESCRIPTION})" unless DESCRIPTION.cover?(d.size)
      out["R3 description repeats the title"] << "#{f}: description repeats the title" if d.strip.casecmp?(fm["title"].to_s.strip)
      nav_title(p, pages, out) if plain
      out["R3 demo pages set twin"] << "#{f}: a layout demo sets twin: explicitly" if demo?(p) && !fm.key?("twin")
      keys = fm.keys & ORDER
      out["R3 key order"] << "#{f}: front matter keys #{keys.join(", ")} are not in the order #{ORDER.join(", ")}" unless keys == ORDER & keys
    end

    # nav_title only as a shorter form of the title: fewer characters and every word of it in the title, or the
    # title's initials (CSP). A translation has one only where its English page has one.
    def nav_title(p, pages, out)
      nt, t = p.fm["nav_title"].to_s, p.fm["title"].to_s
      return if nt.empty?
      words = ->(s) { s.downcase.scan(/[\p{Word}]+/) }
      en = p.lang == pages.tree.default_lang ? p : pages.tree.localized(p, pages.tree.default_lang)
      ok = if en.equal?(p)
             initials = t.scan(/\b\p{Upper}/).join
             (nt.size < t.size && (words.(nt) - words.(t)).empty?) || (nt.size > 1 && nt == initials)
           else
             en&.fm&.key?("nav_title") && nt.size < t.size
           end
      out["R3 nav_title shortens the title"] << "#{p.rel}: nav_title '#{nt}' is not a shorter form of '#{t}'" unless ok
    end

    def demo?(p) = p.key.start_with?("layouts/") && !p.index? && p.key != "layouts/shells.md"

    # nav_order: unique among the pages of one sidebar group (English decides the order for every language).
    def unique_orders(pages, out)
      grouped = pages.docs.select(&:order).reject { |p| p.index? && !p.group } # section indexes follow sections.yml
      grouped.group_by { |p| p.index? ? File.dirname(p.dir) : p.dir }.each do |dir, ps|
        ps.group_by(&:order).each do |o, same|
          next if same.size < 2
          out["R3 unique nav_order"] << "#{dir}: nav_order #{o} on #{same.map(&:rel).join(", ")}"
        end
      end
    end
  end
end
