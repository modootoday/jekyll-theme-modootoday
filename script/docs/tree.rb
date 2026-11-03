# frozen_string_literal: true

require "yaml"
require_relative "../../lib/modootoday/i18n"
require_relative "../../lib/modootoday/stubs/page"

module DocsIndex
  # One docs page: path, language, section and the front matter keys the index reads. key is the path of the
  # English source (guides/install.md for guides/install.ko.md), url the URL the page has or will get.
  Page = Struct.new(:path, :rel, :lang, :section, :group, :key, :fm, :url, keyword_init: true) do
    def index? = File.basename(key) == "index.md"
    def title = fm["nav_title"] || fm["title"]
    def order = fm["nav_order"]
    def listed? = order && !fm["nav_exclude"] && !index?
    def group_index? = index? && group
    def dir = File.dirname(key)
  end

  # Reads docs/: languages from _config.yml, sections from _data/sections.yml, pages from front matter.
  # A page's language comes from its file name (Modootoday::I18n::PageLang), never from the lang: it is given.
  class Tree
    attr_reader :root, :langs, :sections, :pages, :page_lang

    def initialize(root)
      @root = root
      @langs = Array(YAML.safe_load(File.read("#{root}/_config.yml")).dig("modootoday", "languages"))
      @sections = YAML.safe_load(File.read("#{root}/_data/sections.yml"))
      @page_lang = Modootoday::I18n::PageLang.new(@langs, default_lang)
      files = Dir.glob("#{root}/**/*.md").reject { |f| f.delete_prefix("#{root}/").start_with?("_", "vendor/") }.sort
      @pages = files.map { |f| page(f) }
    end

    def default_lang = langs.first || "en"

    def page(path)
      rel = path.delete_prefix("#{root}/")
      fm = Modootoday::Markdown.fm(File.read(path))
      key = page_lang.source(rel)
      parts = key.split("/")
      section = parts.size > 1 ? parts.first : fm["nav_section"]
      group = parts[1] if parts.size > 2
      Page.new(path: path, rel: rel, lang: page_lang.of(rel), section: section, group: group, key: key, fm: fm, url: url(rel, key, fm))
    end

    # A translation's URL is its English source's URL under /<lang>; the generator writes it as permalink:.
    def url(rel, key, fm)
      return Modootoday::Stubs::Page.new(rel, fm).url unless page_lang.translation?(rel)
      src = "#{root}/#{key}"
      src_fm = File.file?(src) ? Modootoday::Markdown.fm(File.read(src)) : {}
      page_lang.url(Modootoday::Stubs::Page.new(key, src_fm).url, page_lang.of(rel))
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
