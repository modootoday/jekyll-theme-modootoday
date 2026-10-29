---
id: adr:modootoday/20261029204502
title: Head metadata on by default; sitemap and feed opt-in; strict CSP option
status: active
created: 2026-10-29T20:45:01Z
updated: 2026-10-29T20:45:01Z
rel:
  governs: [_includes/modootoday/head-meta.html]
---

# Head metadata on by default; sitemap and feed opt-in; strict CSP option

## Context

Sites on classic GitHub Pages cannot add arbitrary plugins, and a theme that called the jekyll-seo-tag tag would fail to parse on sites without that plugin.

## Decision

The default layout emits canonical (when url is set), hreflang alternates for modootoday.languages with x-default, and Open Graph and Twitter card tags, all in Liquid. modootoday.seo: false removes them so a site can use jekyll-seo-tag from its own head include. jekyll-sitemap and jekyll-feed stay opt-in plugins; modootoday.feed: true adds the feed link. modootoday.csp: strict loads the pre-paint script from a file instead of inline so a policy without unsafe-inline works. The docs site demonstrates languages, sitemap and edit_url.

## Consequences

No new plugin dependency. Duplicate tags are possible if a site enables jekyll-seo-tag without seo: false; the configuration docs say so.
