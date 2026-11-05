# frozen_string_literal: true
# modootoday.showcase on the docs starter with a demo overlay: the bar or pill right after the skip link, noindex, the sheet and
# dismiss module only when enabled, the pre-paint flag (inline, or theme-init.js under csp: strict) and the catalog labels.
require "minitest/autorun"
require "tmpdir"
require "open3"
require_relative "../../support/starters"

class ShowcaseTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  DOCS_URL = "https://modootoday.github.io/jekyll-theme-modootoday/"
  USE_URL = "https://github.com/modootoday/jekyll-theme-modootoday-docs-starter/generate"
  OVERLAYS = {
    "bar" => "modootoday:\n  showcase: {enabled: true, starter: docs, docs_url: #{DOCS_URL}, use_url: #{USE_URL}}\n",
    "pill" => "modootoday:\n  color_scheme: light\n  csp: strict\n  showcase: {enabled: true, style: pill, starter: nope, docs_url: #{DOCS_URL}}\n",
    "off" => "modootoday:\n  showcase: {enabled: false, docs_url: #{DOCS_URL}}\n",
  }.freeze

  def self.sites
    @sites ||= begin
      docs = Starters::Sources.path("docs")
      dir = Dir.mktmpdir
      Minitest.after_run { FileUtils.rm_rf(dir) }
      OVERLAYS.to_h do |name, yml|
        File.write("#{dir}/#{name}.yml", yml)
        out, st = Open3.capture2e("bundle", "exec", "jekyll", "build", "-q", "-s", docs, "-d", "#{dir}/#{name}",
                                  "--config", "#{docs}/_config.yml,#{dir}/#{name}.yml", chdir: ROOT)
        raise out unless st.success?
        [name, "#{dir}/#{name}"]
      end
    end
  end

  def html(site, path = "index.html") = File.read(File.join(self.class.sites[site], path))
  def region(h) = h[%r{<div class="mt-showcase-region.*?</div>}m]

  def test_bar_follows_the_skip_link_with_its_links_and_labels
    h = html("bar")
    assert_includes h, '<html lang="en" data-mt-showcase="bar"'
    assert_operator h.index("mt-showcase-region"), :>, h.index('class="mt-skip"')
    r = region(h)
    assert_includes r, 'class="mt-showcase-region mt-showcase-bar" role="region" aria-label="Theme showcase"'
    assert_includes r, "<b>modoo.today theme</b><span class=\"mt-showcase-more\"> · Docs starter · live demo</span>"
    assert_includes r, %(<a href="#{DOCS_URL}" target="_blank" rel="noopener noreferrer" data-mt-new-window>)
    assert_includes r, %(href="#{USE_URL}")
    assert_equal 2, r.scan('<span class="mt-sr-only">, opens in a new window</span>').size
    assert_includes r, '<button class="mt-showcase-dismiss" type="button" aria-label="Hide for this visit">'
    assert_includes region(html("bar", "ko/index.html")), "<b>modoo.today 테마</b><span class=\"mt-showcase-more\"> · 문서 스타터 · 데모</span>"
    assert_includes region(html("bar", "ja/index.html")), "aria-label=\"テーマのショーケース\""
  end

  def test_enabled_showcase_marks_every_page_noindex_and_links_its_assets
    %w[index.html guide/index.html ko/index.html].each do |p|
      h = html("bar", p)
      assert_equal 1, h.scan('<meta name="robots" content="noindex">').size, p
      assert_match %r{<link rel="stylesheet" href="/assets/css/modootoday/chrome/showcase\.css\?v=[^"]+">}, h
      assert_match %r{<script type="module" src="/assets/js/modootoday/chrome/showcase\.js\?v=[^"]+"></script>}, h
      assert_includes h, '<script>try{if(sessionStorage.getItem("mt-showcase"))document.documentElement.dataset.mtShowcase="off"}catch(e){}</script>'
    end
  end

  def test_pill_without_use_url_or_known_starter_and_strict_csp_prepaint
    h = html("pill")
    r = region(h)
    assert_includes r, 'class="mt-showcase-region mt-showcase-pill"'
    assert_includes r, "<p class=\"mt-showcase-label\"><b>modoo.today theme</b></p>"
    refute_includes r, "generate"
    assert_match %r{<script src="/assets/js/modootoday/chrome/theme-init\.js\?v=[^"]+" data-mt-no-theme></script>}, h
    refute_match(/<script>(?!<\/script>)/, h, "no inline script with csp: strict")
  end

  def test_disabled_or_missing_showcase_writes_nothing
    h = html("off")
    %w[mt-showcase-region data-mt-showcase= chrome/showcase noindex data-mt-no-theme].each { |s| refute_includes h, s }
  end

  def test_sheet_offsets_the_header_and_hides_after_dismissal
    css = File.read(File.join(self.class.sites["bar"], "assets/css/modootoday/chrome/showcase.css"))
    assert_match(/\[data-mt-showcase=["]?bar["]?\] \.mt-header\s*\{\s*top:\s*var\(--mt-showcase-top\)/, css)
    assert_match(/\[data-mt-showcase=["]?off["]?\] \.mt-showcase-region/, css)
    assert_match(/\[data-mt-showcase=["]?pill["]?\] body\s*\{\s*padding-bottom/, css)
  end
end
