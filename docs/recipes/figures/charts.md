---
moved_from: [recipes/charts.md]
nav_order: 26
title: Charts
description: Turn a Markdown table into a chart figure, or show a data file as one, with the table as the text every reader gets.
---
# Charts

A chart starts as a Markdown table. The theme puts the table in a chart figure, `figure.mt-chart`, and the table stays inside it as the chart's text: readers without JavaScript, screen readers, github.com, the page's Markdown twin and `llms-full.txt` all get the numbers. With your copy of Chart.js set up, the theme draws the chart from the table and folds the table into a *Chart data* disclosure below it; without it, readers see the table.

## Turn charts on

```yaml
modootoday:
  chart:
    enabled: true
    src: /js/chart.min.js
    integrity: sha384-…
```

`src` is your copy of Chart.js 4 (see [Self-host Chart.js](#self-host-chartjs)); without it, charts stay tables. Without `enabled`, a `chart:` code span stays a code span, as it always has, and `modootoday-check` warns that it is not a chart yet. Front matter `chart: false` keeps one page's charts as tables.

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

This page draws the same chart over four quarters:

`chart:bar stacked`

| Quarter | Docs | Blog |
|---|---|---|
| Q1 | 4,160 | 2,030 |
| Q2 | 5,270 | 2,770 |
| Q3 | 6,020 | 3,140 |
| Q4 | 6,480 | 3,610 |

*Visits per quarter*

The [kitchen sink](../../../components/kitchen-sink/#chart) shows more.

## A chart from a data file

A `c: chart` section shows a file in `_data/charts/`, so one set of numbers can feed several pages:

```yaml
# _data/charts/traffic.yml
label: Month
labels: [Jan, Feb, Mar]
series:
- name: Docs
  values: [1200, 1350, 1610]
- name: Blog
  values: [640, 700, 690]
```

```yaml
sections:
  - c: chart
    name: traffic
    type: line
    data: traffic
```

The theme writes the data as a table at the end of the section: a row per label, a column per series, and `label` above the first column. The section's text comes first, and its last paragraph, when it is emphasis only, is the caption. Labels and series names are text, so give each language its own file (`traffic-ko.yml`) and point the translation at it. `stacked: true` and `horizontal: true` work as the options do above.

A `c: chart` section without `data:` uses its first table instead, captioned the same way as above. A chart section turns its table into a chart figure even when `modootoday.chart.enabled` is off, because the section asks for it by name.

## Colors

The figure carries eight series colors for each scheme, and every one has at least 3:1 contrast with the page background. Set the hooks in your own stylesheet to use your brand's:

```css
:root {
  --mt-chart-1: #0f766e;
  --mt-chart-2: #b45309;
}
```

`--mt-chart-1` to `--mt-chart-8` are the series, `--mt-chart-grid` the grid lines and `--mt-chart-text` the axis text. The theme never sets them, so a value you set applies in both schemes; set it again under your dark-scheme selector to change only the dark one.

## Self-host Chart.js

The theme does not ship Chart.js. Put one pinned copy on your site, so a strict Content Security Policy needs nothing added and no reader request goes to a CDN:

1. Download `dist/chart.umd.min.js` of an exact Chart.js 4 release, for example from `https://cdn.jsdelivr.net/npm/chart.js@4.5.1/dist/chart.umd.min.js`, as `js/chart.min.js`, with its MIT licence beside it as `js/chart.LICENSE.txt`. Keep the licence a `.txt` file: GitHub Pages renders a Markdown file without front matter as a page, so `chart.LICENSE.md` would become one, and `modootoday-check` reports it.
2. Compute its hash: `openssl dgst -sha384 -binary js/chart.min.js | openssl base64 -A`.
3. Set `src: /js/chart.min.js` and `integrity: sha384-<that hash>`.

A CDN works too: `src` is then a version-pinned https URL, `integrity` is required (nothing loads without it), the CDN's origin goes into `script-src`, and readers' IP addresses go to the CDN. `modootoday-check` checks both forms and fails a page that loads any other external script.

Pages load Chart.js (about 70 KB gzip) and the theme's chart module only when they have a chart, after the page is parsed, so the first paint does not wait for them.

## What readers get

- The chart is a `canvas` with `role="img"`, named by the caption (or by the series names when there is none). The table stays in the figure, folded into a *Chart data* disclosure that screen readers and keyboards open like any other. Its accessible name adds the chart's name ("Chart data, Visits"), numbered when two charts share one, so the toggles on a page are told apart.
- Colors, grid lines and axis text come from the hooks above and follow the theme toggle and the system scheme without a reload. Line charts also give each series its own dash pattern, so series stay apart when colors are hard to tell apart; their legend shows each series as a short stroke in that pattern.
- With reduced motion set in the system, charts draw without animation.
- In forced colors mode (Windows high contrast), the chart is not drawn and the table stays open, in the system colors.
- Under a strict CSP the page needs no exception: Chart.js sizes the canvas through the CSSOM, which `style-src 'self'` allows ([CSP](../../csp/)).

## What the checker reports

`modootoday-check` reports, as errors, an unknown type or option, a `chart:` line with no table right after it, a `c: chart` section with both a table and `data:` or with neither, a missing data file and a data file whose series do not have one value per label. A cell or value that is not a number is a warning, reported even when the line's type is wrong. In the built site, a paragraph still holding only a valid `chart:` line is an error when charts are on; one with a wrong type is reported once, from the source. `modootoday.chart.src` must be a version-pinned https URL with `integrity`, or a site path.
