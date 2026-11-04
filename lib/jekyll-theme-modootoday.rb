# frozen_string_literal: true

# md-components v1 — optional generator for Jekyll builds that can load plugins
# (Jekyll 4 / GitHub Actions; NOT the classic GitHub Pages build, which only runs whitelisted plugins).
# Enable with `plugins: [jekyll-theme-modootoday]`. For every Markdown page without a stub it adds the
# same virtual page a hand-written stub would be:
#   <name>.md.txt  {layout: twin, twin_of: <name>.md, permalink: /<name>/index.md}
#   llms.txt / llms-full.txt at / and at /<lang>/ for each language with pages (layouts llms / llms-full)
# so output is identical to the stub-based (GitHub Pages) setup. Existing pages/stubs always win.
require "jekyll"
require_relative "modootoday/stubs/page"

module JekyllThemeModootoday
  class Stub < Jekyll::PageWithoutAFile
    def initialize(site, dir, name, data)
      super(site, site.source, dir, name)
      self.content = ""
      self.data.merge!(data)
      self.data["sitemap"] = false
    end
  end

  class Generator < Jekyll::Generator
    safe true
    priority :lowest

    def generate(site)
      cfg = site.config["modootoday"] || {}
      urls = site.pages.map(&:url).to_h { |u| [u, true] }
      add = lambda do |dir, name, data|
        page = Stub.new(site, dir, name, data)
        next if urls[page.url]

        urls[page.url] = true
        site.pages << page
      end
      md = site.pages.select { |p| p.is_a?(Jekyll::Page) && !p.is_a?(Stub) && p.ext == ".md" && p.name != "README.md" }
      raw = site.static_files.to_h { |f| [f.relative_path.sub(%r{\A/}, ""), true] }
      if cfg.fetch("twins", true)
        md.each do |p|
          next unless Modootoday::Stubs::Page.new(p.relative_path, p.data).twin?
          next if raw[p.relative_path.sub(%r{\A/}, "")] # front-matter-less mode: the source itself is the twin

          url = p.url.end_with?("/") ? "#{p.url}index.md" : p.url.sub(/\.html\z/, ".md")
          d = File.dirname(p.path)
          add.call(d == "." ? "" : d, "#{p.name}.txt", "layout" => "twin", "twin_of" => p.name, "permalink" => url)
        end
      end
      return unless cfg.fetch("llms", true)

      ([""] + llms_langs(site, md)).each do |l|
        url = l.empty? ? "/" : "/#{l}/"
        extra = l.empty? ? {} : { "lang" => l }
        dir = l.empty? || md.none? { |p| p.data["lang"] == l && p.relative_path.start_with?("#{l}/") } ? "" : l
        add.call(dir, "llms.txt", { "layout" => "llms", "permalink" => "#{url}llms.txt" }.merge(extra))
        add.call(dir, "llms-full.txt", { "layout" => "llms-full", "permalink" => "#{url}llms-full.txt" }.merge(extra))
      end
    end

    # Languages with a catalog and at least one page. Pages under <lang>/ keep their llms files there; sibling
    # translations (install.ko.md) get theirs at the root, where the llms layouts list the whole tree.
    def llms_langs(site, md)
      used = md.map { |p| p.data["lang"].to_s }.uniq
      (site.data["i18n"] || {}).keys.select { |l| used.include?(l) && l != site.config["lang"].to_s }
    end
  end
end
