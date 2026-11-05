# frozen_string_literal: true
# The chart renderer: with modootoday.chart.src, pages with a chart load the site's Chart.js and then data/chart.js (with
# its imports preloaded); pages without a chart, with chart: false, or without a usable src load neither.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class ChartScriptTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  CDN = "https://cdn.example.test/chart.js@4.5.1/dist/chart.umd.min.js"
  SRI = "sha384-AAAAbbbbCCCCdddd0123456789+/AAAAbbbbCCCCdddd0123456789+/AAAAbbbbCC"
  CHART = "`chart:bar`\n\n| Month | Visits |\n|---|---|\n| Jan | 1 |\n"

  def self.build(chart)
    dir = Dir.mktmpdir
    src = File.join(dir, "src")
    FileUtils.mkdir_p(src)
    FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
    File.write(File.join(src, "_config.yml"), "title: S\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\n" \
               "defaults: [{scope: {path: ''}, values: {layout: doc}}]\nmodootoday: {chart: #{chart}}\n")
    File.write(File.join(src, "c.md"), "---\ntitle: C\n---\n# C\n\n#{CHART}")
    File.write(File.join(src, "off.md"), "---\ntitle: Off\nchart: false\n---\n# Off\n\n#{CHART}")
    File.write(File.join(src, "plain.md"), "---\ntitle: Plain\n---\n# Plain\n\n| A | B |\n|---|---|\n| x | 1 |\n")
    cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
    Jekyll.logger.log_level = :error
    Dir.chdir(src) { Jekyll::Site.new(cfg).process }
    at_exit { FileUtils.rm_rf(dir) }
    %w[c off plain].to_h { |n| [n, File.read(File.join(dir, "_site", n, "index.html"))] }
  end

  def self.site(key, chart) = (@sites ||= {})[key] ||= build(chart)

  def test_site_path_loads_the_library_then_the_module
    h = self.class.site(:local, "{enabled: true, src: /assets/vendor/chart.umd.min.js, integrity: #{SRI}}")
    lib = %(<script src="/assets/vendor/chart.umd.min.js" integrity="#{SRI}" defer></script>)
    assert_includes h["c"], lib
    mod = h["c"] =~ %r{<script type="module" src="/assets/js/modootoday/data/chart\.js\?v=[^"]+"></script>}
    assert mod, "the chart module loads"
    assert_operator h["c"].index(lib), :<, mod, "Chart.js comes before the module (deferred scripts run in order)"
    assert_includes h["c"], %(<link rel="modulepreload" href="/assets/js/modootoday/data/chart-table.js">)
    assert_includes h["c"], %(<link rel="modulepreload" href="/assets/js/modootoday/theme/current.js">)
    %w[off plain].each { |n| refute_match(/chart\.umd|data\/chart\.js/, h[n], n) }
  end

  def test_cdn_needs_integrity_and_gets_crossorigin
    h = self.class.site(:cdn, %({enabled: true, src: "#{CDN}", integrity: #{SRI}}))
    assert_includes h["c"], %(<script src="#{CDN}" integrity="#{SRI}" crossorigin="anonymous" defer></script>)
    bare = self.class.site(:bare, %({enabled: true, src: "#{CDN}"}))
    refute_match(/chart\.umd|data\/chart\.js/, bare["c"])
  end

  def test_without_src_charts_stay_tables
    h = self.class.site(:tables, "{enabled: true}")
    assert_includes h["c"], '<figure class="mt-chart" data-type="bar">'
    refute_match(/data\/chart\.js/, h["c"])
  end
end
