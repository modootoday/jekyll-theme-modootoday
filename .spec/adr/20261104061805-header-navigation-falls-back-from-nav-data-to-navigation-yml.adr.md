---
id: adr:modootoday/20261104061805
title: "Header navigation falls back from nav data to navigation.yml, header_pages and titled pages"
status: active
created: 2026-11-04T06:18:05Z
updated: 2026-11-04T06:19:09Z
rel:
  governs: [_includes/modootoday/site/nav.html, _includes/modootoday/config.html]
---

# Header navigation falls back from nav data to navigation.yml, header_pages and titled pages

## Context

The header read only `_data/nav/<name>.yml` or a list in `_data/nav.yml`. A minima site lists its header pages in `header_pages`, or lets minima list every titled page; Minimal Mistakes sites keep `main` in `_data/navigation.yml`. After switching themes those sites lost every header link.

## Decision

- `_includes/modootoday/site/nav.html` is the one owner of the header list. It sets `mt_nav`, `mt_nav_source` (`data`, `navigation`, `header_pages` or `auto`) and `mt_nav_groups`. `config.html` includes it in place of its own nav lines, which moved there unchanged.
- Order: `_data/nav/<modootoday.nav>[-<lang>].yml` or a list in `_data/nav.yml`; `main` in `_data/navigation.yml`; `site.header_pages` (page paths, each page with a title); then, from the header include only (`site/nav-auto.html`, once per page), on sites of up to 100 HTML pages, every top-level page of `site.html_pages` (`/about/`, `/about.html`) with a `title` in the page's language, `nav_order` first and then by title. The automatic list leaves out `/`, `nav: false`, `nav_exclude: true`, `hidden: true` and machine or shell layouts (home, redirect, error, twin, llms, feed).
- Jekyll 3's `sort` raises when two values do not compare (a number and a text). Titles therefore sort with `sort_natural` (as text, ignoring case), numeric `nav_order` values with `sort`, and other `nav_order` values as text after them.
- `modootoday.nav: false` turns the automatic list off; the explicit sources still apply. The checker validates `modootoday.nav` as a name or false.
- When the list is made of pages (`header_pages` or automatic), `mt_nav_groups` is false: a page's own `items:` front matter (a directory page) must not become a nav group, and the sidebar and previous/next links stay off, as minima has neither.

## Consequences

Sites without any nav data now get header links: a visible change for theme users who relied on an empty header, who set `nav: false`. The automatic list runs only on sites without any nav source, once per page in the header. Liquid keeps nothing between pages, so it cannot be built once per build: it groups `site.html_pages` by URL depth in Ruby (`group_by_exp`) and loops in Liquid over the top-level pages only. Listing every titled page, as minima does, made a 1,000-record site build more than ten times slower (a list and its links per page, over every page) and is not offered. Grouping is still a pass over the pages on every page, so a site of more than 100 HTML pages skips the list after one size check; such a site needs a nav file, which a site of that size has in practice, and nav data avoids the pass entirely.
