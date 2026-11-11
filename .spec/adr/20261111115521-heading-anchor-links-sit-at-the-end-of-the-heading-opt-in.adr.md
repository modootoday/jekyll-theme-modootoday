---
id: adr:modootoday/20261111115521
title: "Heading anchor links sit at the end of the heading, opt in, with no script"
status: active
created: 2026-11-11T11:55:21Z
updated: 2026-11-11T11:57:58Z
rel:
  governs: [_includes/modootoday/markdown/anchors.html, _sass/modootoday/components/content/_anchor.scss]
  depends_on: [adr:modootoday/20261109141321]
---

# Heading anchor links sit at the end of the heading, opt in, with no script

## Context

Item A1 of [[adr:modootoday/20261109141321]] adds a link from each heading to itself, with no script, in a context sheet of its own. The research behind it put the link after the heading, as a sibling. Two measurements changed that and the details around it:

- The theme's CSS and scripts read headings by adjacency: fourteen Sass selectors such as `.mt-c-accordion > h2 + h3` and `.mt-section > h2:first-child`, and the tabs script, which pairs `:scope > h3` with the code block right after it. A sibling element between a heading and what follows it breaks them.
- kramdown's GFM ids are the same on github-pages 232 (Jekyll 3.10) and Jekyll 4 (kramdown-parser-gfm 1.1.0). `\p{Word}` keeps Hangul, Kana, Han, Arabic, Hebrew and Thai letters, so headings in those scripts get usable ids; CJK punctuation and emoji are dropped. A heading without an id has nothing to link to.

## Decision

- **Opt in.** `modootoday.heading_anchors: true` turns it on; it is off by default, so existing sites build byte for byte as before. The component id is `anchor` (`modootoday.components`, the checker's list, the Text and inline group); a `components:` list without `anchor` turns it off, and the checker warns when the setting is on but the list leaves it out. It is not a key of `docs/_data/components.yml`: that file registers `c:` section components, so a row there would let the checker accept `c: anchor` and the kitchen-sink coverage ask for such a section; like the list styles, it appears in `component_groups.yml` and as a section of the components pages.
- **Placement.** The link is the last child of the heading: `<h2 id="x">Text<a class="mt-anchor" href="#x" aria-label="Link to section: Text"><svg aria-hidden="true">…</svg></a></h2>`. Adjacency selectors keep working, and a link already in the heading closes before the anchor, so links never nest. Only `h2` and `h3` with an id get one.
- **Where.** `markdown/anchors.html` runs from `markdown/sections.html` on the hero, on plain sections (the same gate as the list styles) and on a body without `sections:`. Component sections (`c:`) keep their headings untouched, because tabs, accordions, FAQ, details, steps, timeline and buttons turn them into controls. The table of contents is built before the sections and search reads the source, so neither changes; the Markdown twins and `llms` files are the source as well.
- **Name.** The link is named by the `anchor.label` label, "Link to section: [name]", in all 23 catalogs; the icon holds no text, so `textContent` of the heading, the TOC and the region names stay the heading text.
- **Look.** A new context sheet `content/anchor` (registry row `anchor`, probe `class="mt-anchor`, Sass part `content/anchor`; `css: bundle` folds it in through the parts column). The link shows on hover of the heading and on `:focus-visible`, always under `pointer: coarse`, with a 24 px square target, a logical start margin for right-to-left pages and the system link color in forced colors. The icon is a new `link` name of `brand/icon.html`. The sheet's cap is 384 B: a starter built with Jekyll 4 writes it unminified at 345 B gzip, larger than the plan's estimate of about 200 B, which held only for the compressed docs build.

## Consequences

- A screen reader that reads a heading by its content also reads the link name after the text. This is the cost of keeping the link inside the heading; the shorter name ("Link to section") would lose the heading on a links list.
- Each `##` and `###` heading adds one Tab stop on pages that turn this on; the accessibility guide says so.
- The docs site turns it on, so its heading layout gains the icon on hover and on touch screens.
- A future copy-link variant can reuse `blog/share.js` without changing this markup.
