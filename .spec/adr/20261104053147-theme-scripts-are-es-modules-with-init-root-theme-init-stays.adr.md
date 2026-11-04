---
id: adr:modootoday/20261104053147
title: Theme scripts are ES modules with init(root); theme-init stays classic and search loads on first use
status: active
created: 2026-11-04T05:31:47Z
updated: 2026-11-04T05:33:07Z
rel:
  governs: [assets/js, _includes/modootoday/assets/scripts.html]
  supersedes: [adr:modootoday/20261103053805]
  depends_on: [adr:modootoday/20261102215137, adr:modootoday/20261103033054]
---

# Theme scripts are ES modules with init(root); theme-init stays classic and search loads on first use

## Context

Theme scripts were classic `defer` scripts wrapped in an IIFE, except the filter, which is an ES module (adr:modootoday/20261103033054). `search.js` stayed classic for 1.x (adr:modootoday/20261103053805), so its match rules were copied from `text/normalize.js` and a parity test kept the two in step. Every page with search loaded `search.js` (1,217 bytes gzip) whether or not the visitor searched. Classic scripts cannot be imported by a test or by a site module, so their tests evaluate source text in a page.

Modules suit classic GitHub Pages and `csp: strict`: same-origin module scripts, static and dynamic imports and `modulepreload` are all allowed by `script-src 'self'`, and Pages serves `.js` as `application/javascript`. An import map would need an inline script and is not used.

## Decision

- Each feature is one ES module, `assets/js/modootoday/<ns>/<id>.js`: chrome (menu, theme-toggle, search-keys, search), content (code-copy, scroll-region), structure (tabs, accordion), data (table-stack, filter with `data/filter-chips.js`), blog (share). Shared imports keep their context directories: `dom/config.js`, `text/normalize.js`, `theme/current.js`.
- A module exports `init(root)` and runs `init(document)` when imported. Tests import it and call `init` on their own document.
- `chrome/theme-init.js` stays a classic blocking script in `<head>`: it must run before the first paint, and modules always run deferred.
- `search-keys.js` is loaded on every page with search. It imports `search.js` on the first focus of the box, or on `/`, Ctrl+K or Cmd+K. `search.js` imports `text/normalize.js`, so the match rules have one owner and the parity test goes.
- A registry row lists its static imports in its seventh column; the page gets a `<link rel="modulepreload">` for each, so imports never add a round trip. A test checks the column against the import statements.
- Only the entry URL carries `?v=`; imports and their preloads do not, so their URLs match. Within one minor release, a shared module keeps its export names (a test pins them), because a host that caches each file for ten minutes can briefly mix a new entry with an old import.
- No `nomodule` fallback: without module support, as without JavaScript, every page keeps its content and links.
- The script tags change from `<script src defer>` to `<script type="module" src>` on every page. Both run after parsing, in order, under the same policy. This ships in a minor release, listed under Changed.

## Consequences

Pages without a search interaction load 1,217 bytes less script. Each module is testable by import. Sites that copied a theme script tag by hand must switch to `type="module"`. This supersedes adr:modootoday/20261103053805 and changes the script part of adr:modootoday/20261102215137 (scripts still load only where a page uses them).
