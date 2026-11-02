---
id: adr:modootoday/20261102232226
title: "Site stylesheets and preload hints take site paths only; sheets carry the asset query, hints do not"
status: active
created: 2026-11-02T23:22:26Z
updated: 2026-11-02T23:23:08Z
rel:
  governs: [_includes/modootoday/assets/site-sheets.html, _includes/modootoday/assets/preload.html, lib/modootoday/check/build/site_assets.rb, lib/modootoday/check/config/keys/delivery.rb]
---

# Site stylesheets and preload hints take site paths only; sheets carry the asset query, hints do not

## Context

Sites linked their own CSS from `head-custom.html`, which comes after the inline tokens and cannot be set per page, and had no way to preload a self-hosted font. A strict CSP allows only same-origin files.

## Decision

- `modootoday.site_css` and front matter `site_css:` are lists of site paths to `.css` files. `assets/site-sheets.html` links them after the theme sheets (both CSS modes) and before `tokens.html` and `head-custom.html`, settings first, each once. They go through `assets/url.html`, so they carry the same `?v=` query as the theme files: with `asset_version: build` that invalidates the site's sheets on every deploy.
- `modootoday.preload` and front matter `preload:` are lists of `{href, as, type}`; `href` is a site path and `as` one of font, image, style, script, fetch. `assets/preload.html` writes them at the start of `stylesheets.html`, before any stylesheet, so a site that shadows the default layout keeps them. Fonts and fetches add `crossorigin` because the browser requests them in CORS mode. Hints carry no `?v=` query: a preload must match the URL that `@font-face` or the page requests, or the file is downloaded twice.
- Both keys refuse https and protocol-relative URLs: Liquid skips them and `modootoday-check` reports them, together with any file that is missing from the build. Third-party stylesheets stay in `head-custom.html`, where the site owns the SRI. The two keys join the delivery key group (`config/keys/delivery.rb`) rather than files of their own, because the key directory is at its 12-file limit.
- Values of the wrong shape (a string instead of a list, a map instead of a list of maps) render nothing rather than break the build; the checker names them.

## Consequences

Sites bring brand CSS and fonts as files, per site or per page, under `default-src 'self'; style-src 'self'`. A site without the keys gets byte-identical HTML. Moving existing `head-custom.html` links to `site_css` changes their position in the head (before the inline tokens).
