# frozen_string_literal: true
# Grouped nav: doc sidebar, previous/next across groups, page actions for pages with a Markdown twin,
# and color_scheme auto-dark / auto-light (start scheme printed on <html>, toggle kept).
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class NavigationTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  NAV = <<~YML
    - {title: Start, url: /start/}
    - title: Guides
      items:
        - {title: One, url: /one/}
        - {title: Two, url: /two/}
    - {title: End, url: /end/}
  YML

  def self.site(extra = "", nav = NAV)
    (@s ||= {})[[extra, nav]] ||= begin
      dir = Dir.mktmpdir
      src = File.join(dir, "src")
      FileUtils.mkdir_p(File.join(src, "_data"))
      FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
      File.write(File.join(src, "_data/nav.yml"), nav)
      File.write(File.join(src, "_config.yml"), "title: Site\nurl: https://example.org\npermalink: pretty\n" \
                                                "defaults: [{scope: {path: ''}, values: {layout: doc}}]\n#{extra}")
      %w[start one two end].each { |p| File.write(File.join(src, "#{p}.md"), "---\ntitle: #{p.capitalize}\n---\n# #{p}\n") }
      File.write(File.join(src, "one.md.txt"), "---\nlayout: twin\ntwin_of: one.md\npermalink: /one/index.md\n---\n")
      cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
      Jekyll.logger.log_level = :error
      Dir.chdir(src) { Jekyll::Site.new(cfg).process }
      at_exit { FileUtils.rm_rf(dir) }
      ->(p) { File.read(File.join(dir, "_site", p, "index.html")) }
    end
  end

  def test_sidebar_lists_groups_and_marks_current
    h = self.class.site.call("two")
    assert_includes h, "mt-has-sidebar"
    assert_includes h, '<aside class="mt-doc-nav"><nav class="mt-sidebar"'
    assert_match(%r{<span class="mt-sidebar-title">Guides</span><ul><li><a href="/one/">One</a></li><li><a href="/two/" aria-current="page">Two</a>}, h)
    assert_match(%r{<details class="mt-sidebar-mobile"><summary>Guides</summary>}, h)
  end

  def test_sidebar_off_without_groups_or_when_disabled
    flat = "- {title: Start, url: /start/}\n- {title: One, url: /one/}\n"
    refute_includes self.class.site("", flat).call("one"), "mt-sidebar"
    refute_includes self.class.site("modootoday: {sidebar: false}\n").call("one"), "mt-sidebar"
    assert_includes self.class.site("modootoday: {sidebar: true}\n", flat).call("one"), "mt-doc-nav"
  end

  def test_pagination_follows_group_items
    s = self.class.site
    assert_match(%r{rel="next" href="/one/"><small>Next <svg.*?</small> One}, s.call("start"))
    assert_match(%r{rel="prev" href="/one/">.*rel="next" href="/end/"}m, s.call("two"))
    assert_match(%r{rel="prev" href="/two/"}, s.call("end"))
  end

  def test_page_actions_only_with_twin
    s = self.class.site
    one = s.call("one")
    assert_includes one, 'class="mt-menu mt-page-actions" data-mt-twin="/one/index.md"'
    assert_includes one, 'data-mt-act="ai"'
    assert_includes one, "code-copy.js"
    refute_includes s.call("two"), "mt-page-actions"
    refute_includes self.class.site("modootoday: {page_actions: false}\n").call("one"), "mt-page-actions"
  end

  def test_color_scheme_auto_dark_keeps_toggle_without_fouc
    h = self.class.site("modootoday: {color_scheme: auto-dark}\n").call("one")
    assert_match(/<html [^>]*data-theme="dark"/, h)
    assert_includes h, '<meta name="color-scheme" content="dark light">'
    assert_includes h, "mt-theme-toggle"
    assert_match(/localStorage.getItem\("mt-theme"\)/, h)
    l = self.class.site("modootoday: {color_scheme: auto-light}\n").call("one")
    assert_match(/<html [^>]*data-theme="light"/, l)
    a = self.class.site.call("one")
    refute_match(/<html [^>]*data-theme=/, a)
    d = self.class.site("modootoday: {color_scheme: dark}\n").call("one")
    refute_includes d, "mt-theme-toggle"
  end
end
