---
id: adr:modootoday/20261105130236
title: The web app manifest is derived from existing settings and is installable without the worker
status: active
created: 2026-11-05T13:02:36Z
updated: 2026-11-05T13:02:59Z
rel:
  governs: [_includes/modootoday/pwa/manifest.json, assets/modootoday, lib/modootoday/stubs/pwa.rb]
---

# The web app manifest is derived from existing settings and is installable without the worker

## Context

1.7.0 makes a site installable and readable offline (opt-in `modootoday.pwa`). Chromium offers to install a site that links a web app manifest with a name, a `start_url`, a `display` mode and 192 and 512 px icons; since Chrome 108 no service worker is needed for that. Most of what a manifest says the site already states elsewhere: the title and description, the default language and its direction, the browser bar colour (`modootoday.theme_color`), the brand mark (`favicon: brand`) and the scope (the `baseurl`). A remote theme cannot add files at the site root, so the site needs a generated entry file, as it already does for twins, aliases and record pages (`modootoday-stubs`). Pages off the PWA must not change (no link, no file).

## Decision

- **One manifest per site, rendered by a stub.** `modootoday-stubs --pwa` writes `manifest.webmanifest` (`layout: null`, `permalink: /manifest.webmanifest`, `sitemap: false`) whose body is the include `modootoday/pwa/manifest.json`. `Modootoday::Stubs::Pwa` is the one owner of stub names and contents; `modootoday-check` reads its plan. PWA stubs are never pruned, and a site file already at a stub path is never overwritten (exit 3).
- **No duplicated settings.** `name`, `short_name` and `description` default to the site title and description (`short_name` to `name`); `lang` and `dir` are the default language's (the RTL rule moves into `site/dir.html`, shared with the layouts); `theme_color` is the light value of the theme-color tag (the dark one with `color_scheme: dark`) and is absent with `theme_color: false`; `background_color` defaults to the page background (`#ffffff`, `#0a0a0a` with `color_scheme: dark`); `scope` is always the site root (`"/" | relative_url`) and is not a key; `start_url` is a site path without a query or fragment (no tracking parameters), defaults to the root, and is also the `id`. Keys: `enabled`, `name`, `short_name`, `description`, `display` (`standalone`, `minimal-ui`, `browser`), `start_url`, `icons`, `background_color`.
- **Icons.** `icons: brand` (the default) lists `assets/modootoday/icon-192.png`, `icon-512.png` (purpose `any`) and `icon-maskable-512.png` (purpose `maskable`). They are rendered once from the apple-touch composition, with no new artwork: the favicon mark in `#d94925` on white, the mark's height 73.7 % of the side (matching `apple-touch-icon.png` to a mean channel difference under 0.5/255), and for the maskable icon the hexagon's circumradius at 32 % of the side, inside the 40 % safe zone. The same files serve the docs site ("modoo.today theme", short name "modoo.today"). A list of `{src, sizes, purpose}` takes PNG site paths; a 192 and a 512 icon with purpose `any` are required, a maskable one is recommended. The `apple-touch-icon` link stays with `favicon`.
- **Head.** With `enabled: true` every page that uses the default layout gets `<link rel="manifest">` (`pwa/head.html`, from `head-meta.html`); otherwise nothing is printed. No inline script or style; the manifest is covered by `default-src 'self'` (`manifest-src` falls back to it).
- **Checker.** Config: unknown keys, value shapes, `start_url`, icon list shape and the 192/512 rule (errors); a short name over 12 characters, a list without a maskable icon, and brand icons on a site whose favicon is not the brand mark (warnings). Build, when enabled: the stub is present and current, the built manifest parses and has `id`, `name`, `short_name`, `start_url`, `scope`, `display` and `icons`, `start_url` and `id` sit in the scope, each icon is a PNG in the build whose IHDR size matches `sizes`, and every theme page links the manifest.

## Consequences

A site turns the PWA on with one key, one stub command and nothing else; the app's name, colours and icon follow the settings it already has. A site without the key builds byte-identical HTML; the three icon PNGs (about 38 KB) are theme files and are copied into every gem or remote-theme build like the favicon files. Installability errors are empty in Chromium's default context (an incognito context always reports `in-incognito`, so checks use `browser.contexts()[0]`). The service worker, offline page and kill switch (`enabled: kill`, `precache`) come with the worker commit and extend these keys.
