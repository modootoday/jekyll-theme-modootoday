---
id: adr:modootoday/20261111002632
title: "Manifest shortcuts and screenshots are opt-in site lists, checked against the build"
status: active
created: 2026-11-11T00:26:32Z
updated: 2026-11-11T00:26:51Z
rel:
  governs: [_includes/modootoday/pwa/manifest.json, lib/modootoday/check/config/keys/serving/pwa.rb]
  depends_on: [adr:modootoday/20261105130236, adr:modootoday/20261109141321]
---

# Manifest shortcuts and screenshots are opt-in site lists, checked against the build

## Context

[[adr:modootoday/20261109141321]] adds E9 to 1.7.0: the web app manifest's `shortcuts` (the entries of the app icon's menu) and `screenshots` (the pictures of Chromium's richer install dialog). It was meant to ship with the manifest ([[adr:modootoday/20261105130236]]) and did not. That ADR derives every field from a setting the site already has. Shortcuts could be derived from the top navigation, but the nav serves a different purpose (it changes per language and often links outside the scope), and an app menu that changes whenever the header does would surprise readers. Screenshots cannot be derived at all: they are images the site must provide. Browsers skip screenshots outside their limits (each side 320 to 3840 px, at most 2.3:1), and desktop Chromium shows the richer dialog only with a `form_factor: wide` one.

## Decision

- **Two opt-in keys, nothing derived.** `modootoday.pwa.shortcuts` is a list of `{name, url, short_name, description}`: `name` text and `url` a site path without a query or fragment (the same rule as `start_url`), the others optional text; the manifest prints `url` with the baseurl. `modootoday.pwa.screenshots` is a list of `{src, sizes, form_factor, label}`: `src` a PNG site path, `sizes` `WxH`, `form_factor` `wide` or `narrow`, `label` text; the manifest adds `type: image/png`. Without a key the manifest has no field and is byte-identical to before.
- **No shortcut icons and PNG screenshots only.** Shortcut icons are left out: Chromium falls back to the app icon, and an icon list would need the same size checks as `icons` for little gain. Screenshots are PNG only, so the checker reads their size from the IHDR chunk as it does for icons.
- **Checker.** Config: list and map shapes, unknown keys, text fields, the URL rule, PNG paths, `WxH` sizes and the form factor are errors; a screenshot outside the browsers' limits and a list without a `wide` screenshot are warnings. Build, when enabled: each screenshot is a PNG in the build of the size it states, and each shortcut URL is in the scope and is a page of the build. `modootoday-stubs --pwa` is unchanged: the images and pages are the site's own files.
- **Bytes.** No CSS or JS changes; the manifest grows only by what the site lists.

## Consequences

A site that lists shortcuts gets an app icon menu, and one that lists a wide and a narrow screenshot gets Chromium's richer install dialog on desktop and mobile; the docs site lists none for now. A broken image path or a moved page fails `modootoday-check` instead of silently dropping out of the dialog or the menu.
