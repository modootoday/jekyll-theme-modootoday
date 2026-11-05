---
nav_order: 26
title: Charts
description: Turn a Markdown table into a chart figure, or show a data file as one, with the table as the text every reader gets.
---
# Charts

A chart starts as a Markdown table. The theme puts the table in a chart figure, `figure.mt-chart`, and the table stays inside it as the chart's text: readers without JavaScript, screen readers, github.com, the page's Markdown twin and `llms-full.txt` all get the numbers. Until a chart script draws the figure, readers see the table.

## Turn charts on

```yaml
modootoday:
  chart: {enabled: true}
```

Without this setting, a `chart:` code span stays a code span, as it always has, and `modootoday-check` warns that it is not a chart yet.

## A chart from a table

Put a line holding only `chart:<type>` right before a table, and an emphasis-only line right after it for the caption:

```markdown
`chart:bar stacked`

| Quarter | Docs | Blog |
|---|---|---|
| Q1 | 4,160 | 2,030 |
| Q2 | 5,270 | 2,770 |

*Visits per quarter*
```

- The first column holds the labels and the header row names the series. Every other cell is a number; `,` and `%` are ignored.
- The type is one of `bar`, `line`, `area`, `pie` and `doughnut`.
- Options follow the type, separated by spaces: `stacked` stacks the series, `horizontal` lays bars on their side.

The [kitchen sink](../../components/kitchen-sink/#charts) shows one.

## A chart from a data file

A `c: chart` section shows a file in `_data/charts/`, so one set of numbers can feed several pages:

```yaml
# _data/charts/traffic.yml
label: Month
labels: [Jan, Feb, Mar]
series:
  - {name: Docs, values: [1200, 1350, 1610]}
  - {name: Blog, values: [640, 700, 690]}
```

```yaml
sections:
  - {c: chart, name: traffic, type: line, data: traffic}
```

The theme writes the data as a table at the end of the section: a row per label, a column per series, and `label` above the first column. The section's text comes first, and its last paragraph, when it is emphasis only, is the caption. Labels and series names are text, so give each language its own file (`traffic-ko.yml`) and point the translation at it. `stacked: true` and `horizontal: true` work as the options do above.

A `c: chart` section without `data:` uses its first table instead, captioned the same way as above. A chart section turns its table into a chart figure even when `modootoday.chart.enabled` is off, because the section asks for it by name.

## Colours

The figure carries eight series colours for each scheme, and every one has at least 3:1 contrast with the page background. Set the hooks in your own stylesheet to use your brand's:

```css
:root {
  --mt-chart-1: #0f766e;
  --mt-chart-2: #b45309;
}
```

`--mt-chart-1` to `--mt-chart-8` are the series, `--mt-chart-grid` the grid lines and `--mt-chart-text` the axis text. The theme never sets them, so a value you set applies in both schemes; set it again under your dark-scheme selector to change only the dark one.

## What the checker reports

`modootoday-check` reports, as errors, an unknown type or option, a `chart:` line with no table right after it, a `c: chart` section with both a table and `data:` or with neither, a missing data file and a data file whose series do not have one value per label. A cell or value that is not a number is a warning. In the built site, a paragraph still holding only `chart:` is an error when charts are on.
