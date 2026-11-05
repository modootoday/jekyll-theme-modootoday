---
id: adr:modootoday/20261105075724
title: "Charts render from Markdown tables, the table is the fallback, and colours are sheet hooks"
status: active
created: 2026-11-05T07:57:24Z
updated: 2026-11-05T07:57:54Z
rel:
  governs: [_includes/modootoday/markdown/c/chart.html, _includes/modootoday/markdown/inline/chart.html, _includes/modootoday/chart, _sass/modootoday/components/data]
---

# Charts render from Markdown tables, the table is the fallback, and colours are sheet hooks

## Context

Sites want charts in Markdown pages, and the rules (`md-components v1`) keep a page readable on github.com, in its Markdown twin and without JavaScript. The theme bundles no renderer (adr:modootoday/20261029212621), the core sheet holds only tokens, base and shell (adr:modootoday/20261104053143), and each optional sheet has its own gzip cap (adr:modootoday/20261104053146). A chart script that draws a canvas comes in a later step; this decision fixes the markup, the data shape and the colours it will read.

## Decision

- **The table is the chart.** A paragraph holding only `` `chart:<type> [stacked] [horizontal]` `` right before a GFM table, or a `c: chart` section, renders `figure.mt-chart[data-type][data-opts]` > `div.mt-chart-canvas[hidden]` + `div.mt-chart-data` (the table) + `figcaption`. Types are `bar`, `line`, `area`, `pie` and `doughnut`. The first column holds the labels, the header row the series, the other cells numbers once `,` and `%` are removed. The caption is an emphasis-only paragraph right after the table, the same rule as image figures.
- **Data files become tables in Liquid.** `c: chart` with `data: <name>` writes `site.data.charts[<name>]` (`{label, labels, series: [{name, values}]}`) as a table at the end of the section, labels as row headers (`th[scope=row]`), series as columns, `label` above the first column (an empty cell without it). Its caption is an emphasis-only paragraph that ends the section. A section without `data:` uses its first table. Labels and series names are text, so each language keeps its own data file.
- **Opt-in where it could change output.** The inline form runs only with `modootoday.chart: {enabled: true}` and the `chart` component, so a 1.5 site that has a `chart:` code span builds the same HTML. A `c: chart` section names the component itself and renders without the setting.
- **Section params mirror the inline options:** `type` (required), `stacked`, `horizontal` and `data`. The design listed `stacked` only; `horizontal` is added so both forms say the same things.
- **Colours are hooks in the chart sheet, not core tokens.** `--mt-chart-1` to `--mt-chart-8`, `--mt-chart-grid` and `--mt-chart-text` are never set by the theme. `.mt-chart` resolves them into `--mt-chart-s1` to `--mt-chart-s8`, `--mt-chart-sg` and `--mt-chart-st`, with defaults per scheme under the same selector pair as the token emit, so a script reads one computed value per figure and a site sets a hook once. Light defaults are 700-step hues (#2563eb, #c2410c, #047857, #7c3aed, #a16207, #be185d, #0e7490, #57534e: 4.92 to 7.63:1 on #ffffff) and dark ones 400-step hues (#60a5fa, #fb923c, #34d399, #a78bfa, #facc15, #f472b6, #22d3ee, #a8a29e: 7.27 to 12.93:1 on #0a0a0a), so each series passes 3:1 (WCAG 1.4.11) in both schemes. Grid and text default to `border` and `muted-foreground`.
- **One sheet for both forms.** The `chart` registry row is a context sheet probed by `class="mt-chart`, not a section row, because the inline form has no section. The component-name test accepts a docs component whose sheet is a css row of the same name. The partial is born at its 2.0 path, `components/data/_chart.scss`.
- **The label `chart.data`** is printed as `data-label` on `div.mt-chart-data`, where the chart script finds the summary of the folded table in the page's language.
- **Checker.** Errors: an unknown type or option, a `chart:` line not followed by a table, a section with both or neither of a table and `data:`, an unknown or invalid section `type`, a missing data file, a data file without one value per label, and (with charts on) a `chart:` paragraph left in the build. Warnings: a cell or value that is not a number, and `chart:` spans while charts are off.

## Consequences

Every chart is readable as a table everywhere the page is read, and the later script only adds a canvas. A site recolours charts with plain custom properties and no Sass. Charts cost one optional sheet (cap from the measured size) on pages that have one, and nothing elsewhere. A palette that also stays distinct for colour-vision deficiencies is checked when the script lands; until then the defaults are chosen for contrast and hue spread only.
