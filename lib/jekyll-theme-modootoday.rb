# frozen_string_literal: true

# md-components v1 — optional generator for Jekyll builds that can load plugins
# (Jekyll 4 / GitHub Actions; NOT the classic GitHub Pages build, which only runs whitelisted plugins).
# Enable with `plugins: [jekyll-theme-modootoday]`. For every Markdown page without a stub it adds the
# same virtual page a hand-written stub would be:
#   <name>.md.txt  {layout: twin, twin_of: <name>.md, permalink: /<name>/index.md}
#   llms.txt / llms-full.txt at the root and in each /<lang>/ directory (layouts llms / llms-full)
# so output is identical to the stub-based (GitHub Pages) setup. Existing pages/stubs always win.
require "jekyll"

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
          next if p.data["twin"] == false
          next if raw[p.relative_path.sub(%r{\A/}, "")] # front-matter-less mode: the source itself is the twin

          url = p.url.end_with?("/") ? "#{p.url}index.md" : p.url.sub(/\.html\z/, ".md")
          d = File.dirname(p.path)
          add.call(d == "." ? "" : d, "#{p.name}.txt", "layout" => "twin", "twin_of" => p.name, "permalink" => url)
        end
      end
      return unless cfg.fetch("llms", true)

      langs = (site.data["i18n"] || {}).keys.select { |l| Dir.exist?(File.join(site.source, l)) }
      ([""] + langs).each do |l|
        url = l.empty? ? "/" : "/#{l}/"
        extra = l.empty? ? {} : { "lang" => l }
        add.call(l, "llms.txt", { "layout" => "llms", "permalink" => "#{url}llms.txt" }.merge(extra))
        add.call(l, "llms-full.txt", { "layout" => "llms-full", "permalink" => "#{url}llms-full.txt" }.merge(extra))
      end
    end
  end
end
