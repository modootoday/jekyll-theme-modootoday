# frozen_string_literal: true
# Pins the stylesheet and script tags each page gets: component sheets right after core, context sheets after the bundles
# (probes on the rendered body), section sheets, page css:, bundles and the script conditions, under the default settings
# and two modootoday: variants.
require "minitest/autorun"
require_relative "../../support/layout_site"

class StylesheetProbeTest < Minitest::Test
  include LayoutSite

  SPLIT = "# S\n\nLead.\n\n```sh\nrun\n```\n\n## Plain\n\nText.\n"
  SECTIONS = "# T\n\nLead.\n\n## Install\n\n### npm\n\n```sh\nnpm i\n```\n\n### gem\n\n```sh\ngem i\n```\n\n" \
             "## Questions\n\n### One\n\nA.\n\n## FAQ\n\n### Why\n\nBecause.\n"
  PAGES = {
    "pr/plain.md" => ["title: P\n", "# P\n\nText.\n"],
    "pr/table.md" => ["title: T\n", "# T\n\n| a | b |\n|---|---|\n| 1 | 2 |\n"],
    "pr/spinner.md" => ["title: L\n", "# L\n\n`loading:spinner`\n"],
    "pr/skeleton.md" => ["title: K\n", "# K\n\n`skeleton:card`\n"],
    "pr/topbar.md" => ["title: B\n", "# B\n\n`loading:bar`\n"],
    "pr/svg.md" => ["title: S\n", "# S\n\n![Flow](/assets/flow.svg)\n\n*The flow.*\n"],
    "pr/checks.md" => ["title: C\nhero: {checks: true}\nsections: [plain]\n", "# C\n\nLead.\n\n- Fast\n- Small\n\n## Plain\n\nText.\n"],
    "pr/titled.md" => ["title: I\n", "# I\n\n- **Speed**: very fast\n- **Size**: small\n"],
    "pr/sections.md" => ["title: T\nsections: [{c: tabs, name: t}, {c: accordion, name: a, bleed: true}, {c: faq, name: f}]\n", SECTIONS],
    "pr/split.md" => ["title: S\nhero: {c: split, visual: code, chrome: terminal}\nsections: [plain]\n", SPLIT],
    "pr/css.md" => ["title: X\ncss: [figure, bleed, lists]\nmt_bundle: hero\n", "# X\n\nText.\n"],
    "pr/bare.md" => ["title: N\nchrome: false\n", "# N\n\nText.\n"],
    "pr/blog.md" => ["title: G\nblog_css: true\n", "# G\n\nText.\n"],
    "pr/note.md" => ["title: A\n", "# A\n\n> [!TIP]\n> Tip.\n"],
  }.freeze

  CONFIGS = {
    "default" => "",
    "subset" => "modootoday: {components: [callout, tabs, page-actions, faq], color_scheme: light, loading: true, " \
                "lists: {link_chips: true, titled_items: true}, blog: {share: false}}\n",
    "bundle" => "modootoday: {css: bundle}\n",
  }.freeze

  # "docs/doc.css structure/tabs.js" short names expand to css/modootoday/docs/doc.css and js/modootoday/structure/tabs.js.
  def self.list(s) = s.split.map { |w| w.start_with?("css/", "js/") ? w : "#{w[/\w+\z/]}/modootoday/#{w}" }

  # scroll-region.js and code-copy.js load only on pages whose body has a <pre> (scroll-region.js also for a <table>).
  CHROME = "chrome/menu.js content/scroll-region.js content/code-copy.js chrome/theme-toggle.js"
  PLAIN = "chrome/menu.js chrome/theme-toggle.js"
  SEARCH = "search.js chrome/search-keys.js"
  DEFAULT = {
    "pr/plain" => "css/modootoday.css chrome/doc-nav.css docs/doc.css chrome/search.css #{PLAIN} #{SEARCH}",
    "pr/table" => "css/modootoday.css chrome/doc-nav.css docs/doc.css chrome/search.css data/table.css chrome/menu.js content/scroll-region.js chrome/theme-toggle.js #{SEARCH}",
    "pr/spinner" => "css/modootoday.css chrome/doc-nav.css docs/doc.css chrome/search.css content/loading.css #{PLAIN} #{SEARCH}",
    "pr/skeleton" => "css/modootoday.css chrome/doc-nav.css docs/doc.css chrome/search.css content/loading.css #{PLAIN} #{SEARCH}",
    "pr/topbar" => "css/modootoday.css chrome/doc-nav.css docs/doc.css chrome/search.css content/loading.css #{PLAIN} #{SEARCH}",
    "pr/svg" => "css/modootoday.css chrome/doc-nav.css media/figure.css docs/doc.css chrome/search.css #{PLAIN} #{SEARCH}",
    "pr/note" => "css/modootoday.css chrome/doc-nav.css content/inline.css docs/doc.css chrome/search.css #{PLAIN} #{SEARCH}",
    "pr/checks" => "css/modootoday.css chrome/doc-nav.css marketing/hero.css docs/doc.css chrome/search.css content/lists.css #{PLAIN} #{SEARCH}",
    "pr/titled" => "css/modootoday.css chrome/doc-nav.css docs/doc.css chrome/search.css #{PLAIN} #{SEARCH}",
    "pr/sections" => "css/modootoday.css content/code.css chrome/doc-nav.css marketing/hero.css docs/doc.css chrome/search.css structure/bleed.css structure/tabs.css structure/accordion.css structure/faq.css " \
                     "structure/tabs.js #{CHROME} structure/accordion.js #{SEARCH}",
    "pr/split" => "css/modootoday.css content/code.css chrome/doc-nav.css marketing/hero.css docs/doc.css chrome/search.css chrome/terminal.css structure/split.css #{CHROME} #{SEARCH}",
    "pr/css" => "css/modootoday.css chrome/doc-nav.css media/figure.css css/modootoday-hero.css docs/doc.css chrome/search.css content/lists.css structure/bleed.css #{PLAIN} #{SEARCH}",
    "pr/bare" => "css/modootoday.css chrome/doc-nav.css docs/doc.css chrome/search.css chrome/theme-toggle.js #{SEARCH}",
    "pr/blog" => "css/modootoday.css chrome/doc-nav.css css/modootoday-blog.css docs/doc.css chrome/search.css #{PLAIN} blog/share.js #{SEARCH}",
    "." => "css/modootoday.css content/code.css chrome/doc-nav.css content/inline.css marketing/hero.css css/modootoday-hero.css docs/doc.css chrome/search.css structure/bleed.css showcase/cta.css showcase/card.css " \
           "structure/tabs.css structure/tabs.js #{CHROME} #{SEARCH}",
    "guide" => "css/modootoday.css content/code.css chrome/doc-nav.css content/inline.css docs/doc.css chrome/search.css data/table.css #{CHROME} #{SEARCH}",
    "blog:." => "css/modootoday.css chrome/doc-nav.css content/inline.css css/modootoday-blog.css chrome/search.css chrome/menu.js content/code-copy.js chrome/theme-toggle.js blog/share.js #{SEARCH}",
  }.freeze
  # components: has no code-copy, theme-toggle or search; page-actions still brings code-copy on pages with a twin.
  SUBSET = {
    "pr/plain" => "css/modootoday.css docs/doc.css content/loading.css chrome/menu.js",
    "pr/svg" => "css/modootoday.css docs/doc.css content/loading.css chrome/menu.js",
    "pr/note" => "css/modootoday.css content/inline.css docs/doc.css content/loading.css chrome/menu.js",
    "pr/titled" => "css/modootoday.css docs/doc.css content/loading.css content/lists.css chrome/menu.js",
    "pr/sections" => "css/modootoday.css content/code.css marketing/hero.css docs/doc.css content/loading.css structure/bleed.css structure/tabs.css structure/faq.css structure/tabs.js chrome/menu.js content/scroll-region.js",
    "pr/split" => "css/modootoday.css content/code.css marketing/hero.css docs/doc.css content/loading.css chrome/terminal.css chrome/menu.js content/scroll-region.js",
    "pr/bare" => "css/modootoday.css docs/doc.css content/loading.css",
    "pr/blog" => "css/modootoday.css css/modootoday-blog.css docs/doc.css content/loading.css chrome/menu.js",
    "guide" => "css/modootoday.css content/code.css content/inline.css docs/doc.css content/loading.css data/table.css chrome/menu.js content/scroll-region.js content/code-copy.js",
    "blog:." => "css/modootoday.css content/inline.css css/modootoday-blog.css content/loading.css chrome/menu.js content/code-copy.js",
  }.freeze
  BUNDLE = {
    "pr/svg" => "css/modootoday.css #{PLAIN} #{SEARCH}",
    "pr/note" => "css/modootoday.css #{PLAIN} #{SEARCH}",
    "pr/sections" => "css/modootoday.css structure/tabs.js #{CHROME} structure/accordion.js #{SEARCH}",
    "pr/css" => "css/modootoday.css css/modootoday-hero.css #{PLAIN} #{SEARCH}",
    "pr/bare" => "css/modootoday.css chrome/theme-toggle.js #{SEARCH}",
    "blog:." => "css/modootoday.css css/modootoday-blog.css chrome/menu.js content/code-copy.js chrome/theme-toggle.js blog/share.js #{SEARCH}",
  }.freeze

  { "default" => DEFAULT, "subset" => SUBSET, "bundle" => BUNDLE }.each do |config, pages|
    define_method("test_#{config}_tags") { assert_tags(pages.transform_values { |w| self.class.list(w) }, config) }
  end

  def self.sites = @sites ||= {}

  # One build per config and starter, shared by the tests; returns the built site directory. The docs starter
  # gets PAGES; "blog:<page>" keys name a page of the blog starter.
  def site(name, starter)
    self.class.sites[[name, starter]] ||= begin
      dir = Dir.mktmpdir
      Minitest.after_run { FileUtils.rm_rf(dir) }
      build_site(dir, starter == "docs" ? PAGES : {}, config: CONFIGS[name], starter: starter)[1]
    end
  end

  # Stylesheet and script URLs of one built page, in document order, without the /assets/ prefix.
  def tags(name, key)
    starter, page = key.include?(":") ? key.split(":", 2) : ["docs", key]
    h = File.read(File.join(site(name, starter), page, "index.html"))
    h.scan(%r{<link rel="stylesheet" href="/assets/([^"?]+)[^"]*"|<script (?:type="module" )?src="/assets/([^"?]+)[^"]*"}).map { |a, b| a || b }
  end

  # Every page of a config in one comparison, so one run shows every difference.
  def assert_tags(expected, name) = assert_equal(expected, expected.to_h { |page, _| [page, tags(name, page)] }, name)
end
