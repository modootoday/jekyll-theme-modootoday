---
id: adr:modootoday/20261102215137
title: Theme asset URLs carry the theme version by default; scripts load only where a page uses them
status: active
created: 2026-11-02T21:51:37Z
updated: 2026-11-02T21:52:06Z
rel:
  governs: [_includes/modootoday/assets, _includes/modootoday/version.html, script/version-include]
---

# Theme asset URLs carry the theme version by default; scripts load only where a page uses them

## Context

GitHub Pages serves every file with `Cache-Control: max-age=600` and ignores query strings. Sites that put a CDN in front want to cache the theme's CSS and JavaScript for a long time, which needs a URL that changes when the files change. The theme also loaded `code-copy.js` and `scroll-region.js` on every page, although they act only on code blocks and tables (and the page actions menu).

## Decision

- Every theme stylesheet and script URL comes from `modootoday/assets/url.html`, which appends `?v=` and `mt_asset_v`. `modootoday.asset_version` sets it: `theme` (default) is the theme version, `build` adds the first 7 characters of `site.github.build_revision` or, when the builder passes none, `site.time` as seconds, and `false` adds nothing.
- The version comes from `_includes/modootoday/version.html`, generated from the gemspec by `script/version-include`; a test fails when the two disagree. A remote_theme build has no gem to ask, so Liquid needs the value in a file.
- The default is on, which changes the built HTML of every site once. Only the theme's CSS and JavaScript get the query; images, fonts and site assets keep their URLs.
- Registry rows for scripts may carry a body probe like sheets do. `scroll-region.js` loads when the rendered body has a `<pre` or a `<table`, the elements it handles; `code-copy.js` loads when the body has a `<pre`, or, as before, on pages with the page actions menu. Matching the elements the scripts select keeps their behaviour on every page that has them, tab panels included. No JavaScript bundle mode.

## Consequences

Sites can cache theme files for a year on a CDN and keep the HTML short-lived. Every release changes every asset URL, so an unchanged file is fetched again after an upgrade; `asset_version: false` restores the old URLs. Pages without code or tables load two fewer scripts. Releases must run `script/version-include` after bumping the version (RELEASING.md step 1).
