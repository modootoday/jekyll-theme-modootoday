# frozen_string_literal: true

require "yaml"
require "date"

module DocsIndex
  FM = /\A---\n(.*?)\n---\n/m

  # One docs page: path, language, section and the front matter keys the index reads.
  Page = Struct.new(:path, :rel, :lang, :section, :group, :key, :fm, keyword_init: true) do
    def url
      return fm["permalink"] if fm["permalink"].to_s.end_with?("/")
      "/#{rel.delete_suffix(".md").delete_suffix("index")}".sub(%r{([^/])\z}, '\1/')
    end
    def index? = File.basename(rel) == "index.md"
    def title = fm["nav_title"] || fm["title"]
    def order = fm["nav_order"]
    def listed? = order && !fm["nav_exclude"] && !index?
    def group_index? = index? && group
    def dir = File.dirname(key)
  end

  # Reads docs/: languages from _config.yml, sections from _data/sections.yml, pages from front matter.
  class Tree
    attr_reader :root, :langs, :sections, :pages

    def initialize(root)
      @root = root
      @langs = Array(YAML.safe_load(File.read("#{root}/_config.yml")).dig("modootoday", "languages"))
      @sections = YAML.safe_load(File.read("#{root}/_data/sections.yml"))
      @pages = Dir.glob("#{root}/**/*.md").reject { |f| f.delete_prefix("#{root}/").start_with?("_", "vendor/") }
                  .sort.map { |f| page(f) }
    end

    def default_lang = langs.first || "en"

    def page(path)
      rel = path.delete_prefix("#{root}/")
      parts = rel.split("/")
      lang = langs.include?(parts.first) && parts.first != default_lang ? parts.shift : default_lang
      fm = YAML.safe_load(File.read(path)[FM, 1].to_s, permitted_classes: [Date]) || {}
      section = parts.size > 1 ? parts.first : fm["nav_section"]
      group = parts[1] if parts.size > 2
      Page.new(path: path, rel: rel, lang: lang, section: section, group: group, key: parts.join("/"), fm: fm)
    end

    # Nav entries under a directory key ("guides" or "components/forms") for one language: its pages, plus
    # each group (subdirectory with an index.md) as one entry. A page missing in `lang` falls back to the default.
    def entries(dir, lang)
      base = pages.select { |p| p.lang == default_lang && p.order && !p.fm["nav_exclude"] }
      base = base.select { |p| (p.listed? && (p.dir == dir || (p.section == dir && p.dir == "."))) || (p.group_index? && p.dir == "#{dir}/#{p.group}") }
      base.map { |p| localized(p, lang) || p }.sort_by { |p| [p.order, p.key] }
    end

    def index_of(dir, lang)
      localized(pages.find { |p| p.lang == default_lang && p.key == "#{dir}/index.md" }, lang)
    end

    def localized(page, lang)
      return page if page.nil? || lang == page.lang
      pages.find { |p| p.lang == lang && p.key == page.key }
    end
  end
end
