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
  After the fix (f521efb) the same object reads:
  `warning: _site/event/index.html: JSON-LD Offer (@graph.offers) lacks required price/priceSpecification; set the offer in front matter: schema: {offers: {type: Offer, price: ..., priceCurrency: ...}} (tickets: alone gives only its url) (a warning in a nested object, an error from 2.0)`.
  The second warning for `priceCurrency` stays: it is a second required property.
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

## Status

Fixed in four commits on top of this audit: 45a05ee (scroll regions, figure names, chart summaries and legend),
f521efb (checker messages), e8a5a2c (docs, en/ko/ja) and d34a8b2 (legend keys keep the series dash). The release
candidate's visual review added five findings (V1 to V5); V1 and V2 are deferred.

| Finding | Status | Commit | Change |
|---|---|---|---|
| M1 remote rendering undocumented | fixed | e8a5a2c | Math and diagrams, "Where the browser runs": a browser is needed for diagrams, not math; `--cdp=URL` with any Chrome DevTools endpoint and `CDP_AUTHORIZATION`; a CI job that fails on uncommitted renders. The usage given there matches the script's usage line. |
| m1 event front matter, twin 404 | fixed | e8a5a2c | The Event demo shows its front matter and links the Detail pages guide; Structured data, "Checking", links the event example; the Event and Events directory demos have Markdown twins. |
| m2 digest.mjs not linked | fixed | e8a5a2c | Linked in "Static math" and "Keep diagrams fresh". |
| m3 licence as Markdown | fixed | f521efb, e8a5a2c | One error: "a licence file saved as Markdown becomes a page on GitHub Pages; save it as js/chart.LICENSE.txt, or list it in exclude:". The math key rule needs math blocks; stale math names a shared file only when one is shared. The recipe names `js/chart.LICENSE.txt`. |
| m4 check without SITE | fixed | f521efb | Says SITE is missing and prints the build-and-check command above the usage. |
| m5 readConfig import | fixed | e8a5a2c | The widget recipe shows the import line and the named export. |
| m6 theme `?v=` on site modules | kept, documented | e8a5a2c | Kept: site modules and sheets follow the same rule as `site_css`. Widgets and Performance say to use `asset_version: build` when a site's own files change between theme releases. |
| m7 README list | fixed | e8a5a2c | Charts and Widgets in README and README.ko. |
| m8 showcase merge snippet | fixed | e8a5a2c | Configuration shows the guarded workflow steps the starters use. |
| m9 two errors for one chart type | fixed | f521efb | One source error; the cell warnings still appear; the build check quotes only valid unconverted lines. |
| m10 regions that fit are tab stops | fixed | 45a05ee | `scroll-region.js` takes figure scrollers too and drops their tab stop while they fit. Remote check: no figure tab stop at 1280 (en, ko); the diagram is one at 360 (en, ja). |
| m11 identical Chart data names | fixed | 45a05ee | Summaries are named "Chart data, <caption>", numbered when captions repeat. |
| m12 diagram region named by alt | fixed | 45a05ee | Region named "Diagram, <caption>" (or "Diagram"); the alt text stays on the image. |
| Nested Offer warning | fixed | f521efb | Quoted above under "Checker messages found ambiguous". |
| V1 diagram SVG text English on ko/ja | deferred | | Follow-up for 1.7, below. |
| V2 diagram text about 10 px at 360 | deferred | | Follow-up for 1.7, below. |
| V3 dashed legend key looks like a block | fixed | 45a05ee, d34a8b2 | Line and area legends draw a short stroke in the series' dash. |
| V4 "Table, Tables 1" and number gaps | fixed | 45a05ee | A heading that repeats the label is dropped; numbers count only live regions. Remote check: kitchen sink en/ko/ja at 360 and 1440, no duplicate, no gap. |
| V5 event offers not on the page | fixed | e8a5a2c | "Admission: free" on the page; the offer has `availability` and `url`. |

Verification: remote Chrome 152 through a tunnel on the strict-CSP docs build, axe (wcag2a/aa, 21a/aa, 22aa,
best-practice) 0 violations on 26 loads of the changed pages (en light 1440 and dark 360; ko and ja at 360).

## Follow-up for 1.7

- **V1. Diagram SVG text is English on ko and ja pages.** The pixels of `recipes/flow.svg` keep the English node
  labels; alt text and caption are translated. Proposal: give each translation its own `diagrams:` entry
  (`recipes/flow-ko`, `recipes/flow-ja`) rendered from a translated fence, so one SVG pair per language; the
  checker already compares each entry with its own fence. Until then, the recipe can say that one SVG is shared.
- **V2. Diagram text is about 10 px at 360.** The 818 x 63 flowchart is drawn at the 32rem figure minimum.
  Proposal: let a `diagrams:` entry set its own minimum render width (a `min_width:` that overrides
  `--mt-figure-min-width` for that figure), and redraw the docs flowchart top-down (`flowchart TD`) so its
  aspect suits a narrow column.
