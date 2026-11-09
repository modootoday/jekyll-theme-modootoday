---
nav_order: 50
title: Roadmap
description: What the theme supports today, which stacks it runs on, and the themes of the work planned next.
---
# Roadmap

## Supported now

- Every component on the [Components](../../components/) page, in light and dark, from inline text to page sections and site chrome.
- Every layout in the [Public API](../api/#layouts) list: doc pages, page shells, directories, detail pages, marketing pages, blog and news, docs extras and documents.
- Content rules (`md-components v1`) that stay plain GitHub Markdown, and a stable [public API](../api/).
- Canonical, `hreflang` and Open Graph tags by default; sitemap and feed when you add the plugins.
- A language switcher, interface labels in every language of the language list, and right-to-left scripts (see the [RTL kitchen sink](../../components/kitchen-sink-rtl/)).
- Markdown twins and `llms.txt` for AI agents ([AI agents](../../guides/agents/)).
- Diagrams, math and charts as static figures, and your own interactive elements ([Figures and widgets](../../recipes/figures/)).
- Pages generated from data files on classic GitHub Pages ([Generated pages](../../recipes/generated-pages/)), and header search with a list filter ([Search](../../recipes/search/)).
- A strict Content Security Policy ([CSP](../../recipes/csp/)).
- Documentation in English, Korean and Japanese.

## Compatibility

- The stacks the theme runs on are listed under [Install > Requirements](../../guides/install/#requirements).
- Changes to the public API are listed in the [Changelog](../changelog/); [Migrate and upgrade](../../guides/upgrade/) says what to change in a site.

## Next

The work planned next, in no promised order. New components and options are added without breaking existing sites.

- Page footer links: edit this page, report an issue and a short feedback question, with no script and no analytics.
- Heading anchor links, feed discovery links and a print stylesheet.
- Release pages and download tables built from GitHub Releases.
- Freshness: a last-updated date, a notice on translations that lag their source, and sitemap dates.
- Code line highlighting, and search results that open at the matching heading.
- Image zoom and a reading progress bar without script, and reading offline from an installed site.
- Checker rules for image alt text and image sizes.
