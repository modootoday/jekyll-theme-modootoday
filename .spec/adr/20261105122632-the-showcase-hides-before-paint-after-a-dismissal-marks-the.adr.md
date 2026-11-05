---
id: adr:modootoday/20261105122632
title: "The showcase hides before paint after a dismissal, marks the build noindex and uses region-scoped class names"
status: active
created: 2026-11-05T12:26:32Z
updated: 2026-11-05T12:27:03Z
rel:
  governs: [_includes/modootoday/chrome/showcase.html, assets/js/modootoday/chrome/theme-init.js, _sass/modootoday/components/chrome/_showcase.scss]
  depends_on: [adr:modootoday/20261104170401, adr:modootoday/20261104171141]
---

# The showcase hides before paint after a dismissal, marks the build noindex and uses region-scoped class names

## Context

[[adr:modootoday/20261104170401]] decides the showcase of a starter demo build: a config-enabled bar or pill, its offsets, its dismissal for the visit and its assets. [[adr:modootoday/20261104171141]] decides that an enabled showcase marks the build `noindex`. Building it (1.6.0) left four points those decisions do not settle, and showed one they get wrong:

- 170401 puts the showcase's links before the skip link in focus order. axe treats a link as a skip link only when it precedes every link to another page, so with the showcase first, "Skip to content" lies outside every landmark and axe best-practice `region` fails on every page of a demo (measured on the docs, blog and landing starters, both styles, en/ko/ja). The skip link first is also the usual order (WCAG technique G1).
- The bar is drawn on every page by Liquid. After a dismissal, a deferred module would hide it only after the first paint, so the next page would move up.
- The pre-paint script that already exists, `chrome/theme-init.js`, loads only with the theme toggle, and its one line applies a stored colour scheme. On a demo with a fixed scheme it would override the site's choice: every starter demo and the docs share the origin `modootoday.github.io`, so a scheme chosen on the docs is in storage.
- The hero visual `showcase` already uses `.mt-showcase` and `.mt-showcase-*` classes, and the hero bundle sets `.mt-showcase {display: contents}`. A landing demo can load both.
- The measured sheet is larger than the plan's estimate.

## Decision

- **Focus order (amends 170401).** The showcase region comes right after the skip link, before the banner and the header: Tab reaches "Skip to content", then the showcase's links and its dismiss button. After a dismissal, focus returns to the skip link.
- **One attribute carries the state.** `<html data-mt-showcase>` is `bar` or `pill` as Liquid writes it, and `off` after a dismissal. The sheet keys the header offset, `scroll-padding-top`, the menu height, the sticky sidebar and table of contents (`bar`) and the page's bottom padding (`pill`) on it, so `off` resets all of them with no extra rules.
- **Pre-paint.** The dismiss module (`chrome/showcase.js`) sets `off` and stores `sessionStorage["mt-showcase"]`. Before the next page paints, a line reads the flag and sets `off` on a page that has a showcase: inline by default, in `theme-init.js` under `modootoday.csp: strict`. The theme-init file now loads when the toggle or the showcase is on; when only the showcase is on, its tag carries `data-mt-no-theme` and the stored colour scheme is not applied. The file measures 247 B gzip against its unchanged 256 B cap.
- **Class names.** The region is `div.mt-showcase-region` with `.mt-showcase-bar` or `.mt-showcase-pill`; its parts are `.mt-showcase-mark`, `p.mt-showcase-label`, `a.mt-showcase-solid` (the filled link), `button.mt-showcase-dismiss`, `.mt-showcase-more` (hidden below 40rem) and `.mt-showcase-less` (shown only there). The bare `.mt-showcase` stays the hero visual's.
- **Contents.** The label is the catalog's theme name (`showcase.theme`, "modoo.today theme"), then the starter's label (`showcase.starters.<name>`, when a catalog has it) and `showcase.demo`. Links name themselves in full, with the existing new-window hint in a visually hidden span, so the accessible name says the link opens a new window; the built-site check skips the region when it looks for `aria-describedby`. The pill shows the theme and starter names, a short Docs link and the dismiss button.
- **noindex** is written by the default layout whenever the showcase is on, next to the page and layout switches. `modootoday-check` reads `_config.demo.yml` as well as `_config.yml` for the key and warns about built pages without the tag; its sample-link heuristic for `noindex` pages skips a showcase build.
- **Budget.** The sheet holds both styles, the offsets, the short-viewport rule and the forced-colours borders: 919 B gzip as built with Dart Sass (the plan's 797 B draft lacked the sidebar, menu and short-viewport offsets). Its cap is 1,024 B, the measured size plus 10% rounded up to 128 ([[adr:modootoday/20261104053146]]). The dismiss module is 326 B against a 384 B cap. The core sheet is unchanged.

## Consequences

- A site without `modootoday.showcase` builds the same HTML as before; it only gains the compiled `chrome/showcase.css`, which no page links.
- A theme-init change that adds bytes now needs a cap raise.
- Demo builds fail Lighthouse's SEO "is crawlable" audit by design; starter QA reads performance and accessibility only.
- The docs QA page type for the kitchen sink is renamed from `showcase` to `components`, so "showcase" means only the demo bar.
