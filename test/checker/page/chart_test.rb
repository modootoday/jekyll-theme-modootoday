# frozen_string_literal: true
# Charts (page/chart.rb, config/keys/figures/chart.rb, the build residue): the h01-chart fixtures with
# modootoday.chart on, c: chart sections and their data files, and the setting itself. Run: bundle exec rake test
require_relative "../checker_case"

class CheckChartTest < CheckerCase
  FIX = File.expand_path("../../fixtures/md", __dir__)
  ON = "modootoday: {chart: {enabled: true}}\n"
  TABLE = "| Month | Visits |\n|---|---|\n| Jan | 1200 |\n"
  DATA = "labels: [Jan, Feb]\nseries: [{name: Visits, values: [1200, 1500]}]\n"

  def fixture(name) = page("#{name}.md", "---\n---\n#{File.read(File.join(FIX, "#{name}.md"))}")

  def test_fixtures_with_charts_on
    page "_config.yml", ON
    %w[h01-chart-ok h01-chart-no-table h01-chart-bad-type h01-chart-cells].each { |n| fixture(n) }
    o, code = check
    assert_equal 1, code, o
    assert_includes o, "h01-chart-no-table.md: `chart:line` must be alone in a paragraph right before a table"
    assert_includes o, "h01-chart-bad-type.md: `chart:radar`: the type must be one of bar, line, area, pie, doughnut"
    assert_includes o, "h01-chart-bad-type.md: `chart:bar wide`: unknown option wide (stacked, horizontal)"
    assert_includes o, "h01-chart-cells.md: `chart:line`: row 2 cell 'n/a' is not a number"
    refute_match(/h01-chart-ok/, o)
  end

  def test_spans_stay_code_while_charts_are_off
    fixture "h01-chart-ok"
    o, code = check("--strict")
    assert_equal 1, code
    assert_includes o, "h01-chart-ok.md: `chart:` stays a code span until _config.yml sets modootoday.chart.enabled: true"
  end

  def test_sections
    page "_data/charts/traffic.yml", DATA
    page "_data/charts/short.yml", "labels: [Jan, Feb]\nseries: [{name: Visits, values: [1200]}]\n"
    page "_data/charts/text.json", %({"labels": ["Jan"], "series": [{"name": "Visits", "values": ["many"]}]})
    secs = [{ "type" => "line", "data" => "traffic" }, { "type" => "bar" }, { "type" => "bar" }, { "type" => "pie", "data" => "traffic" },
            { "type" => "radar", "stacked" => "maybe", "data" => "nope" }, { "type" => "line", "data" => "short" }, { "type" => "area", "data" => "text" }]
    yaml = secs.each_with_index.map { |s, i| "{c: chart, name: s#{i}, #{s.map { |k, v| "#{k}: #{v}" }.join(', ')}}" }.join(", ")
    page "a.md", "---\nsections: [#{yaml}]\n---\n# A\n\n## S0\n\nLead.\n\n## S1\n\n#{TABLE}\n## S2\n\nNo table.\n\n## S3\n\n#{TABLE}\n" \
                 "## S4\n\nX.\n\n## S5\n\nX.\n\n## S6\n\nX.\n"
    o, code = check
    assert_equal 1, code
    refute_match(/sections\[[01]\]/, o)
    assert_includes o, "a.md: sections[2] chart: needs a table or data: <name> (_data/charts/<name>.yml)"
    assert_includes o, "a.md: sections[3] chart: has a table and data:; keep one"
    assert_includes o, "a.md: sections[4] chart: type must be one of bar, line, area, pie, doughnut"
    assert_includes o, "a.md: sections[4] chart: stacked must be true or false"
    assert_includes o, "a.md: sections[4] chart: data: \"nope\" needs _data/charts/nope.yml (or .json)"
    assert_includes o, "a.md: sections[5] chart: _data/charts/short.yml must be {labels: [...], series: [{name, values}]} with one value per label"
    assert_includes o, "a.md: sections[6] chart: _data/charts/text.json value \"many\" is not a number"
  end

  def test_setting_and_build_residue
    page "_config.yml", "modootoday: {chart: {enabled: maybe, src: /x.js}}\n"
    page "a.md", "---\n---\n# A\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "_config.yml: modootoday.chart.enabled must be true or false"
    page "_config.yml", ON
    out "a/index.html", "<p><code>chart:bar</code></p>\n<p>Mentions <code>chart:bar</code>.</p><pre><code>chart:bar</code></pre>"
    o, code = check
    assert_equal 1, code
    assert_equal 1, o.scan("unconverted chart").size, o
  end
end
