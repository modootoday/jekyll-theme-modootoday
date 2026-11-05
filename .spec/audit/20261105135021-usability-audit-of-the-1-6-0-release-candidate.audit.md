---
id: audit:modootoday/20261105135021
title: Usability audit of the 1.6.0 release candidate
status: active
created: 2026-11-05T13:50:21Z
updated: 2026-11-05T13:50:21Z
rel:
  governs: [docs]
---

# Usability audit of the 1.6.0 release candidate

## Scope

A first-time user evaluates commit d078da6 (after release 1.5.0) using only the public documentation site
and the public README. The documentation site already showed the Charts, Widgets and static-math recipes,
so the d078da6 deploy was live. The theme's source tree, internal notes and earlier audits were not read.
Scripts that the recipes tell a user to copy (math.mjs, digest.mjs, diagrams.mjs) were downloaded and
run as instructed.

Tasks:

1. An empty site with `remote_theme`, a build and `modootoday-check` (a 1.5 regression).
2. Each 1.6 feature from the upgrade guide's 1.6 entry and the recipes: a static Mermaid diagram, static
   math, a chart from a Markdown table with self-hosted Chart.js, a widget, the event `tickets:` and its
   structured-data warning, the starter demo showcase, and `header.compact_title` on a logo site at a
   narrow viewport.
3. Accessibility: axe on a chart, widget, math and diagram page, the home page and a post (an event page
   too), and a keyboard-only pass on the chart toggle, the widget control and the scroll regions.

## Method

- Ruby 3.3, `github-pages` 232, `remote_theme: modootoday/jekyll-theme-modootoday@d078da6` plus
  `repository:` for the local build. Deviation: the docs pin `@v1.5.0`, and the upgrade guide's 1.6 row
  names `@v1.6.0`, which does not exist yet; the commit was pinned instead.
- The checker came from the d078da6 source archive, the Install guide's "without installing a gem"
  route, with the archive URL changed from the tag to the commit. Deviation: no 1.6 gem exists yet.
- Twins: `modootoday-stubs . --twins --write` and the two `llms` stub files, as the Install guide says.
- Browsers: no local browser was allowed. All rendering, axe and keyboard checks ran in a remote Chrome
  152 over CDP, with the built site served through a temporary tunnel.
- Axe 4.13.0, twice: the runner's default rule set (7 pages, light), and a second run with
  `runOnly` tags wcag2a, wcag2aa, wcag21a, wcag21aa, wcag22aa and best-practice (7 pages light, 7 dark,
  4 at 360 px).
- Grades: blocker = could not finish from the docs; major = finished only by guessing, or the first
  result was wrong; minor = friction.

## Times

| Task | Wall time | Notes |
|---|---|---|
| 1. Empty site, build, check | about 2 min | bundle install 6 s, build 7.5 s, check 0.3 s; passed after the stub step |
| 2. 1.6 features | about 21 min | about 8 min of it waiting for a shared build lock; about 13 min of active work |
| 2a. Static diagram | about 5 min | most of it finding a way to render without a local browser |
| 2b. Static math | about 2 min | worked first try; plus the lock wait for `npm install katex` |
| 2c. Chart | about 3 min | the licence file broke the first check (see m3) |
| 2d. Widget | about 3 min | writing the 30-line element; worked first try |
| 2e. Event tickets | about 2 min | warning matched the docs; fix copied from the docs |
| 2f. Demo showcase | about 1 min | `--config _config.yml,_config.demo.yml` worked first try |
| 2g. Compact title | about 1 min | checked during task 3 |
| 3. Accessibility | about 7 min | two tunnel runs: axe, keyboard pass, screenshots |

## Findings

### Blockers

None. Every task finished.

### Major

- **M1. Static diagrams need a local browser, and the remote option is undocumented.**
  (recipes/math-diagrams, "Static diagrams" and "Keep diagrams fresh"). The recipe offers two ways to
  render the SVG pair: the Mermaid CLI through `npx` (which downloads and launches a headless Chromium)
  and the repository's `diagrams.mjs`, which "needs Node and Playwright". Both start a browser on the
  machine. The script also accepts `--cdp=URL` and a `CDP_AUTHORIZATION` variable to drive a browser
  elsewhere, but the recipe does not say so; I found it only in the script's usage line. I finished by
  calling the script's `renderAll` with a remote browser of my own. A user in CI without a browser, or
  on a locked-down machine, has no documented path. Suggest: document `--cdp`, and say plainly that
  rendering needs a browser while math does not.

### Minor

- **m1. Event front matter is hard to find.** (layouts/detail/event, layouts/detail). The Event demo
  page shows the result but no front matter; the `tickets:` example lives on the Detail pages index,
  and Structured data, "Checking", which describes the `offers` warning, does not link to it. The
  "View as Markdown" twin of the Event demo (and the Events directory demo) returns the 404 page.
- **m2. "Copy it with digest.mjs" without a link.** (recipes/math-diagrams, "Static math" and "Keep
  diagrams fresh"). Only `math.mjs` and `diagrams.mjs` are linked; I guessed that `digest.mjs` sits in
  the same folder (it does).
- **m3. A licence saved beside Chart.js as Markdown breaks the check.** (recipes/charts, "Self-host
  Chart.js"). The recipe says to keep the MIT licence beside the file; the package names it
  `LICENSE.md`. Saved as `js/chart.LICENSE.md`, the checker reports three errors, and one points the
  wrong way (quoted below). Renaming to `.txt` fixed it. Suggest naming the file in the recipe.
- **m4. `modootoday-check .` prints only the usage.** The upgrade guide's step 3 reads as if the source
  alone can be checked; without SITE the checker prints three usage lines and exits 1 with no hint.
- **m5. The widget recipe does not say how to import `readConfig`.** (recipes/widgets, "Write the
  element"). The path is in Customize, "Module scripts and posters", and the export style (named) had to
  be guessed. It worked first try.
- **m6. The site's own widget files get the theme version as `?v=`.** The built page links
  `/assets/js/widgets/x-counter.js?v=1.5.0`, so editing my own module does not change its URL, and the
  release candidate still reports 1.5.0. Performance, "Versioned asset URLs" covers `asset_version`,
  but the widget recipe does not mention it.
- **m7. The README's documentation list lacks Charts and Widgets.** Math and diagrams is listed; the two
  new recipes are not.
- **m8. The showcase merge step for classic GitHub Pages is described, not shown.**
  (guides/configuration, "Starter demo showcase"). It says the starters merge `_config.demo.yml` into
  `_config.yml` in a guarded workflow step, but gives no snippet. Locally the documented
  `--config` form worked; the Pages path was not exercised.
- **m9. Two errors for one wrong chart type, and a masked warning.** `chart:lines` gives a source error
  and a second build error ("unconverted chart"); a non-number cell in the same table is reported only
  after the type is fixed.
- **m10. Scroll regions are tab stops even when nothing scrolls.** Both formula regions (at 1280 and
  360 px) and the diagram region (at 1280 px) take focus although their content fits
  (scrollWidth equals clientWidth). Three extra stops on two short pages.
- **m11. Several disclosures share the name "Chart data".** With two charts on a page, a screen reader
  user hears the same summary twice; the summary is not tied to the chart's caption.
- **m12. The diagram region is named by the full alt text.** The region and the image inside it carry
  the same long sentence, so it is read twice.

### Checker messages found ambiguous

- `js/chart.LICENSE.md: math key "js--chart.LICENSE" is not a data file name Jekyll keeps; set math_key: to letters, digits, - and _`
  (a licence file with no math; the real problem is that it is a page at all).
- `warning: _site/event/index.html: JSON-LD Offer (@graph.offers) lacks required price/priceSpecification; fix it now (in a nested object this is an error from 2.0)`
  (names the JSON-LD path, not the front matter that fixes it, `schema: {offers: ...}`; "fix it now"
  before the parenthesis reads oddly; the same object gives a second warning for `priceCurrency`).
- `math.md:12: stale math: entry 1 of _data/math/math.yml was rendered from other TeX than this block (...); pages with the same key share the file; render them again (modootoday-check SRC --math lists them)`
  (on a site with one math page, "pages with the same key share the file" is noise).
- `_site/charts/index.html: unconverted chart (a paragraph with only <code>chart:)` (repeats the source
  error for the same line; no line number or type).

Clear and actionable: the missing twin message, the missing `width`/`height` warning (it prints the
values), "stale diagram", the inline-math error, the unknown widget element, the unknown chart type, the
non-number cell, and the showcase-in-`_config.yml` warning.

### What worked first try

- Task 1: build and `--twins --strict` passed after the documented stub step.
- `--diagrams` and `--math` listings: exact files, digests and reasons, as documented.
- Static math: `npm install --save-dev katex` and `modootoday-check . --math | node _scripts/math.mjs .`,
  no browser; two `<math>` blocks on the page.
- Chart: both tables became `figure.mt-chart`, Chart.js loaded from the self-hosted path with
  `integrity`, bars and line drawn, the table folded into "Chart data".
- Widget: section and paragraph forms both upgraded, the fallback hidden once defined, props read.
- Event: the documented `schema: {offers: ...}` cleared both warnings; `--strict` failed on them before,
  plain mode passed, as the upgrade guide says.
- Showcase: bar region "Theme showcase", `noindex` on every page, checker clean.
- Compact title: at 360 px the header shows only the logo; the site name stays in the link, visually
  hidden.

## Accessibility

### Axe

| Run | Pages | Violations | Passes | Incomplete |
|---|---|---|---|---|
| Default rule set, light | home, post, chart, widget, math, diagram, event | 0 on every page | 36 to 40 | 1 on math, 1 on the post, 0 elsewhere |
| Tags wcag2a/aa, 21a/aa, 22aa, best-practice, light | same 7 | 0 | not recorded | not recorded |
| Same tags, dark | same 7 | 0 | not recorded | not recorded |
| Same tags, 360 px | math, diagram, chart, widget | 0 | not recorded | not recorded |

### Keyboard-only pass

- Chart toggle: each "Chart data" summary is a tab stop with a visible ring; Enter opens it and Space
  closes it again. Issue: identical names (m11).
- Widget control: both counter buttons are tab stops with a visible ring; Enter and Space each add a
  step (3 became 5).
- Scroll regions: each formula and the diagram is a named, focusable region with a visible ring. At
  360 px the diagram region scrolled 120 px with three ArrowRight presses. Issues: regions that do not
  overflow still take focus (m10); long region name (m12).
- Order: skip link, site title, navigation, theme toggle, breadcrumb, page actions, content, then the
  "On this page" links at desktop width. No traps; focus returns to the document after the last stop.
