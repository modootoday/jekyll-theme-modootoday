# frozen_string_literal: true
# Charts: a chart: code span before a table and c: chart sections (a table, or data: from _data/charts) render the same
# figure.mt-chart around a table, link the chart sheet, and change nothing while modootoday.chart is off.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "jekyll"

class ChartTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  TABLE = "| Month | Visits | Signups |\n|---|---|---|\n| Jan | 1,200 | 30% |\n| Feb | 1,500 | 42% |\n"
  INLINE = "---\ntitle: Inline\n---\n# Inline\n\n`chart:bar stacked horizontal`\n\n#{TABLE}\n*Visits by month*\n\nAfter.\n\n" \
           "`chart:pie`\n\n#{TABLE}\nNo caption.\n\n`chart:radar`\n\n#{TABLE}\n`chart:line`\n\nNo table.\n\nMentions `chart:bar` in prose.\n"
  SECTIONS = "---\ntitle: Sections\nsections: [{c: chart, name: d, type: line, data: traffic}, {c: chart, name: t, type: bar, stacked: true}, " \
             "{c: chart, name: m, type: area, data: missing}]\n---\n# Sections\n\n## Data\n\nLead text.\n\n*Visits, 2026*\n\n" \
             "## Table\n\nLead.\n\n#{TABLE}\n*From the table*\n\nTail.\n\n## Missing\n\nNothing to draw.\n"
  DATA = "label: Month\nlabels: [Jan, Feb, \"<Mar>\"]\nseries:\n  - {name: Visits, values: [1200, 1500, 1700]}\n  - {name: Signups, values: [30, 42, 51]}\n"

  def self.build(chart)
    dir = Dir.mktmpdir
    src = File.join(dir, "src")
    FileUtils.mkdir_p(File.join(src, "_data/charts"))
    FileUtils.cp_r(%w[_layouts _includes _sass assets].map { |d| File.join(ROOT, d) }, src)
    File.write(File.join(src, "_config.yml"), "title: S\nmarkdown: kramdown\nkramdown: {input: GFM}\npermalink: pretty\n" \
               "defaults: [{scope: {path: ''}, values: {layout: doc}}]\n#{chart ? "modootoday: {chart: {enabled: true}}\n" : ''}")
    File.write(File.join(src, "_data/charts/traffic.yml"), DATA)
    File.write(File.join(src, "inline.md"), INLINE)
    File.write(File.join(src, "sections.md"), SECTIONS)
    File.write(File.join(src, "plain.md"), "---\ntitle: Plain\n---\n# Plain\n\n#{TABLE}")
    cfg = Jekyll.configuration("source" => src, "destination" => File.join(dir, "_site"), "quiet" => true)
    Jekyll.logger.log_level = :error
    Dir.chdir(src) { Jekyll::Site.new(cfg).process }
    at_exit { FileUtils.rm_rf(dir) }
    %w[inline sections plain].to_h { |n| [n, File.read(File.join(dir, "_site", n, "index.html"))] }
  end

  def on = (@@on ||= self.class.build(true))
  def off = (@@off ||= self.class.build(false))
  def main(h) = h[%r{<main.*</main>}m]
  def figures(h) = main(h).scan(%r{<figure class="mt-chart".*?</figure>}m)

  def test_inline_chart_wraps_the_table_and_takes_the_caption
    f = figures(on["inline"])
    assert_equal 2, f.size, main(on["inline"])
    head = '<figure class="mt-chart" data-type="bar" data-opts="stacked horizontal"><div class="mt-chart-canvas" hidden></div>' \
           '<div class="mt-chart-data" data-label="Chart data"><div class="mt-table"><table>'
    assert f[0].start_with?(head), f[0]
    assert f[0].end_with?("</table></div></div><figcaption>Visits by month</figcaption></figure>"), f[0]
    assert_match(%r{\A<figure class="mt-chart" data-type="pie"><div class="mt-chart-canvas" hidden></div>.*</table></div></div></figure>\z}m, f[1])
    refute_includes main(on["inline"]), "<em>Visits by month</em>"
    assert_includes main(on["inline"]), "<p>No caption.</p>"
  end

  def test_unknown_types_and_lone_spans_stay_code
    m = main(on["inline"])
    %w[chart:radar chart:line chart:bar].each { |v| assert_match(%r{<code[^>]*>#{v}</code>}, m) }
  end

  def test_data_section_renders_the_data_as_a_table
    sec = main(on["sections"])[/<section[^>]*data-section="d".*?<\/section>/m]
    assert_includes sec, "<p>Lead text.</p>"
    assert_match(%r{<figure class="mt-chart" data-type="line">.*<thead>\s*<tr><th scope="col">Month</th><th scope="col">Visits</th><th scope="col">Signups</th></tr>}m, sec)
    assert_includes sec, %(<tr><th scope="row">&lt;Mar&gt;</th><td>1700</td><td>51</td></tr>)
    assert_includes sec, "<figcaption>Visits, 2026</figcaption>"
    refute_includes sec, "<em>Visits, 2026</em>"
  end

  def test_table_section_wraps_its_first_table
    sec = main(on["sections"])[/<section[^>]*data-section="t".*?<\/section>/m]
    assert_match(%r{<p>Lead.</p>\s*<figure class="mt-chart" data-type="bar" data-opts="stacked">.*<figcaption>From the table</figcaption></figure>\s*<p>Tail.</p>}m, sec)
    assert_match(/<section class="mt-section mt-c-chart" data-section="t" data-c="chart">/, sec)
  end

  def test_missing_data_leaves_the_section_as_written
    sec = main(on["sections"])[/<section[^>]*data-section="m".*?<\/section>/m]
    refute_includes sec, "mt-chart\""
    assert_includes sec, "<p>Nothing to draw.</p>"
  end

  def test_sheet_only_on_chart_pages
    %w[inline sections].each { |n| assert_match %r{href="/assets/css/modootoday/data/chart\.css\?v=[^"]+"}, on[n], n }
    refute_includes on["plain"], "chart.css"
    refute_includes off["inline"], "chart.css"
  end

  def test_off_by_default_the_page_is_unchanged
    m = main(off["inline"])
    assert_empty figures(off["inline"])
    assert_match(%r{<p><code[^>]*>chart:bar stacked horizontal</code></p>}, m)
    assert_equal main(on["plain"]), main(off["plain"])
  end
end
