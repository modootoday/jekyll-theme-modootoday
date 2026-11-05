---
id: adr:modootoday/20261105093428
title: "Charts are drawn by the site's own Chart.js, loaded before the chart module, and the table stays the fallback"
status: active
created: 2026-11-05T09:34:28Z
updated: 2026-11-05T09:34:58Z
rel:
  governs: [_includes/modootoday/render/chart.html, assets/js/modootoday/data/chart.js, assets/js/modootoday/data/chart-table.js]
---

# Charts are drawn by the site's own Chart.js, loaded before the chart module, and the table stays the fallback

## Context

Charts render as tables inside `figure.mt-chart` (adr:modootoday/20261105075724), with an empty `div.mt-chart-canvas[hidden]` and the colour hooks resolved on the figure. The theme bundles no renderer (adr:modootoday/20261029212621), theme scripts are ES modules with pinned import names (adr:modootoday/20261104053147), every theme file has its own gzip cap (adr:modootoday/20261104053146), and the docs site runs under `csp: strict`. A spike showed Chart.js 4 drawing under `script-src 'self'; style-src 'self'` with zero violations, because it sizes the canvas through the CSSOM.

## Decision

- **The site supplies Chart.js 4.** `modootoday.chart` gains `src` and `integrity`, checked by the same rules as the Mermaid and KaTeX URLs: a version-pinned https URL with an SRI hash (printed with `crossorigin="anonymous"`), or a site path with an optional hash. Without `src`, charts stay tables; that is not a warning, since a table-only chart is a valid choice.
- **The library tag comes first.** `assets/scripts.html` includes `render/chart.html` on pages whose body hits the `chart` module row's probe (`class="mt-chart`); it prints the library as a deferred classic script and only then puts `chart` in the module list, so the module tag follows it and deferred scripts run in document order. An https `src` without `integrity`, `enabled` false, or front matter `chart: false` prints neither.
- **The module draws, the table stays.** `data/chart.js` reads each figure's table through `data/chart-table.js` (labels in the first column, series in the header row, numbers after removing `,` and `%`, gaps as `null`), appends a `canvas` with `role="img"` named by the caption (or the series names), shows the box, and folds the table into a `details` whose `summary` is the figure's `data-label` (`chart.data`). Types map to Chart.js `bar`, `line` (area is a filled line at 20% of a `#rrggbb` hook), `pie` and `doughnut`; `stacked` and `horizontal` set the axes. It imports `theme/current.js` for scheme changes; it reads `data-type` and `data-opts` directly, so it does not import `dom/config.js`.
- **Colours are read, not set.** Series, grid and text colours are the figure's resolved `--mt-chart-s1..s8`, `-sg` and `-st`. On `mt:themechange` or a system scheme change each chart is destroyed and drawn again with the new values and no animation, so the toggle needs no reload. Line series also get dash patterns, the fallback the plan named for colour-vision deficiency.
- **Readers who asked for less get less.** Under `prefers-reduced-motion: reduce` charts draw without animation. Under `forced-colors: active` the module draws nothing and the table stays open; the sheet also hides the canvas box if forced colours start later.
- **Palette rule.** A unit test keeps every default series at 3:1 or more on its scheme's background and adjacent series at CIELAB distance 15 or more under Machado (2009) severity-1 protan, deutan and tritan simulation (lowest today: 17.1). Non-adjacent pairs may collide; the dash patterns and the table cover them.
- **Budgets.** `data/chart.js` is about 1.4 KB gzip, cap 1,664, above the plan's 950-byte estimate: folding, naming, scheme redraw, motion, forced colours, direction and dashes cost more than estimated, and the source stays unminified like every theme module. `data/chart-table.js` keeps its 512 cap. The docs QA adds a `chart` page type that is left out of the page targets (`GUIDE.skip`), since Chart.js itself is about 70 KB gzip; the theme's part is still held to the sum of its caps.
- **Docs site.** It self-hosts Chart.js 4.5.1 (`docs/assets/js/chart/`, MIT licence and source note beside it, bytes identical to the npm and CDN copies). 4.5.1 replaces the spike's 4.4.1: it is the newest release older than two weeks on 2026-11-05, and the only advisory on record for the package (GHSA-h68q-55jf-x68w) was fixed in 2.9.4.

## Consequences

A site gets drawn charts by adding one file and two keys, and everything that reads the page without scripts still gets the table. The theme carries no third-party code and no CSP exception. Chart pages cost the library plus about 2 KB of theme script, and nothing elsewhere. The interaction paths (hover tooltip, legend click) are covered by the docs QA under the strict policy.
