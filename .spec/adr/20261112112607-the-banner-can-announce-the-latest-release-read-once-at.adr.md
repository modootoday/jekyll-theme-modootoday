---
id: adr:modootoday/20261112112607
title: The banner can announce the latest release, read once at build time
status: active
created: 2026-11-12T11:26:07Z
updated: 2026-11-12T12:08:36Z
rel:
  governs: [_includes/modootoday/chrome/banner-text.html, _includes/modootoday/chrome/banner.html, lib/modootoday/check/config/keys/appearance/chrome.rb]
  depends_on: [adr:modootoday/20261109141321, adr:modootoday/20261112023954]
---

# The banner can announce the latest release, read once at build time

## Context

R2 in [[adr:modootoday/20261109141321]]: a project site wants every visitor to see that a release is out, without a script that calls an API from the browser.

## Decision

- `modootoday.banner` keeps `text:` (with `url:`, `link:`) as before. Without `text:`, `release: latest` reads `site.github.latest_release` when the site is built (GitHub already leaves prereleases out) and `release: {version, url}` takes the values given; either fills "[version] is out." and a "What's new" link to the release. No release, no banner.
- The banner markup moves from `_layouts/default.html` to `chrome/banner.html`; `chrome/banner-text.html` resolves it once for the markup and for the banner sheet's condition. No new CSS; two labels in all 23 catalogs.
- `modootoday-check` requires `text:` or `release:`, checks the release's shape, and shares the `site.github` warning with `edit_url: auto`.
- The banner is as fresh as the last build, so the updates recipe pairs it with a rebuild on each published release. The docs site leaves it off.

## Consequences

- Tests: `test/theme/chrome/banner_test.rb` (latest from a `github:` map, the map form, text winning, no release, the sheet) and the checker's message snapshot.
