---
id: adr:modootoday/20261110133153
title: "An opt-in service worker with build-versioned, scope-prefixed caches and a kill switch"
status: active
created: 2026-11-10T13:31:53Z
updated: 2026-11-10T13:32:25Z
rel:
  governs: [_includes/modootoday/pwa, assets/js/modootoday/pwa, _layouts/pages/offline.html, lib/modootoday/stubs/pwa.rb]
  depends_on: [adr:modootoday/20261105130236]
---

# An opt-in service worker with build-versioned, scope-prefixed caches and a kill switch

## Context

[[adr:modootoday/20261105130236]] made a site installable with a web app manifest and left the service worker, the offline page and the switch-off path to the next step. A worker is the one theme feature that outlives a deploy: once registered, it keeps answering requests from a visitor's device until a newer `sw.js` replaces it, so a bug or a careless removal can serve stale pages for months. GitHub Pages cannot send `Service-Worker-Allowed` or cache headers, a remote theme cannot add files at the site root, and project sites share one origin (`<user>.github.io`), so their caches live side by side. Pages off the PWA must not change.

## Decision

- **A Liquid stub with constants, a static theme script with the strategies.** The site's `sw.js` stub (`modootoday-stubs --pwa`, at the baseurl root because a worker's scope is its folder) renders `_includes/modootoday/pwa/sw.js`: with `enabled: true` it sets `self.MT_PWA` (scope, versions, precache list, offline page per language prefix) and imports `assets/js/modootoday/pwa/worker.js`, a classic script that node tests run in a fake worker global. The theme file is cached like any other and has its own registry row and cap.
- **The kill switch ships with the first worker, inline.** With `enabled: kill`, and with `false` or no key while the stub exists, `sw.js` is a self-removing worker written into the include itself (no import): it skips waiting, deletes this scope's caches, unregisters and reloads open pages. A broken `worker.js` can therefore never block the rollback. PWA stubs are never pruned; the checker warns when a disabled site keeps `sw.js`. The documented rollback is `kill`, a week deployed, then `false` and deleting the stubs.
- **Versions.** `build` is the theme version plus the short commit (`site.github.build_revision`), else the build time, whatever `asset_version` says, so `sw.js` changes on every deploy and browsers find the new worker. `assets` follows the `?v=` contract: the theme version with `asset_version: theme` (the default), else `build`. One include (`assets/build.html`) computes `build` for the registry and the worker.
- **Caches named per scope.** `mt:<scope>:assets:<assets>`, `mt:<scope>:pages:<assets>` (amended below; first `<build>`) and `mt:<scope>:media`, where the scope is the baseurl root. Activation and the kill worker delete only names that start with `mt:<scope>:`, so another project site on the origin keeps its caches.
- **Routes.** Only same-origin `GET` requests inside the scope without a `Range` header are handled; any handler that throws falls through to the network. Theme files are cache first; navigations network first with navigation preload and no timeout (freshness over speed), falling back to the kept copy and then the offline page of the longest language prefix, with a 5xx also served from the kept copy; only `ok`, non-redirected responses are stored; pages are trimmed to the 50 most recently used, never a precached one. `search.json` and images and fonts (60 entries) are stale while revalidate; site CSS and JS network first; Markdown twins, `llms*.txt`, feeds, the sitemap, the manifest and `sw.js` network only.
- **Precache.** The offline pages, the theme files they link (one owner: `pwa/offline-assets.html`, which a test compares with built offline pages), `start_url`, `pwa.precache` and pages with front matter `pwa: precache`, as versioned URLs. Only a missing offline page fails the install. The checker fails on a precache URL missing from the build and warns over 1 MiB; the docs site reports its total in QA with a 150 KiB guide target.
- **First visit.** The first page is not controlled while it loads, so `pwa/register.js` posts the in-scope URLs it fetched to the worker once it is active, and an offline start is styled.
- **Offline page.** Layout `pages/offline` on `minimal`, noindex, out of the sitemap, search and twins, no title (so title-based lists skip it), a Try again link with `href=""` that needs no script, a home link, and a hidden list that `pwa/offline.js` fills from this scope's pages cache, titles read with `DOMParser` and inserted as text. One offline page per site language in `full_languages`; one manifest per site.
- **Privacy.** No analytics, push, background sync, periodic sync or `persist()`; no cookies or Web Storage; nothing is sent anywhere.

## Consequences

A site turns offline reading on with one key and the stub command; a site without the key builds the same HTML. A PWA page loads one more module (`pwa/register.js`, 636 B gzip, cap 768); the offline page also loads `pwa/offline.js` (674 B, cap 768); the worker script (1,799 B, cap 2,048) is loaded by the worker only, not by a page. Visited pages kept offline stay until the theme files change (see the amendment). The browser flows (offline, update, kill, two scopes on one origin) are checked on fixture builds in a later step; the update notice and the silent activation of page-only deploys come with it.

## Amendment (2026-11-10): the pages cache follows the theme files, not the build

The pages cache was first named by the build, so every deploy dropped the pages a reader had kept for offline reading. With the update notice, a deploy that keeps the theme files activates its worker at once, so on a site that deploys content daily a reader would rarely find a visited page offline. The pages cache is now `mt:<scope>:pages:<assets>`: it survives deploys that keep the theme files, and it is replaced together with the assets cache when they change, because a kept page links the theme files of its own version and would be unstyled once those are deleted. Pages are network first, so a kept copy is only ever served offline or on a server error, where an older copy is the point. The worker also leaves navigations to Markdown twins, `llms*.txt`, feeds and the sitemap to the network, as the route table always said; they were classified as pages first and kept.
