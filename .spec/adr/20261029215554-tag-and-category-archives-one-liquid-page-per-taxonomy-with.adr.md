---
id: adr:modootoday/20261029215554
title: "Tag and category archives: one Liquid page per taxonomy with anchors"
status: active
created: 2026-10-29T21:55:54Z
updated: 2026-10-29T21:56:08Z
rel:
  governs: [_includes/modootoday/archive.html]
---

# Tag and category archives: one Liquid page per taxonomy with anchors

## Context

The roadmap listed tag and category archive pages for the post layout. The docs site and most users build on classic GitHub Pages (github-pages, Jekyll 3.10), which runs no custom plugin, so a generator that writes one page per tag (jekyll-archives style) is not available there. The theme must behave the same on Jekyll 4, keep the Markdown rules unchanged and pass the docs QA gate (axe, contrast, size budgets) in light, dark and RTL.

## Decision

Archives are Liquid only: the include modootoday/archive.html (by: tags or categories, optional lang) and the archive layout (front matter archive: and archive_lang:) render one page per taxonomy with an index of terms and post counts, then one section per term with id <by>-<slugified term>, newest post first. An archive lists posts in the page language (post lang, else site.lang) unless lang is all. modootoday.archive: {tags:, categories:} gives the archive URLs; when set, the post layout adds a footer linking each term to its section, prefixed with /<lang> for posts whose lang differs from site.lang. modootoday-check validates the setting and skips Markdown twins for files under _posts/, whose dated URLs do not follow the page path. Styles live in the post component, reuse the tag badge and use logical properties; post is added to the component list so its CSS is shipped.

## Consequences

Archives work unchanged on github-pages and Jekyll 4 without plugins. A term has an anchor, not its own URL; sites that need per-term pages can add a generator plugin on Actions builds and keep the same footer links by pointing modootoday.archive at their pages. Posts have no twin and are not in llms-full.txt; agents reach them through the archive. Liquid loops over site.tags for every archive page, which is fine for hundreds of posts but grows with posts x terms. The archive layout, the include and its parameters, the archive i18n keys and modootoday.archive are public API under the deprecation policy.
