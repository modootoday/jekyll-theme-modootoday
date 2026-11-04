---
id: adr:modootoday/20261104115309
title: A long site name takes a second header line and ends in an ellipsis
status: active
created: 2026-11-04T11:53:09Z
updated: 2026-11-04T11:53:51Z
rel:
  governs: [_sass/modootoday/components/core/chrome/_header.scss, _layouts/default.html]
---

# A long site name takes a second header line and ends in an ellipsis

## Context

The header is one 4rem row at every width (adr:modootoday/20261103205338). `.mt-site-title` was `nowrap` with `overflow: hidden` and no ellipsis, so a name wider than its space ended in a cut glyph: "modoo.t" at 360px, "modoo.toda" at 390px and "modoo.today t" at 1024px beside the inline nav, in Korean and RTL too, and "Static Agent Marketp" on a real site. At 360px the search, language, theme and menu buttons leave the name about 75px; at 1024px the inline nav leaves it about 130px. The title text was an anonymous flex item, which `text-overflow` cannot reach.

Options weighed: a single line with an ellipsis (always safe, but hides most of a two-word name); hiding the inline nav earlier than 64rem (moves a breakpoint every nav, sidebar and sheet rule shares, and does not help phones); a smaller type step alone (not enough at 360px); two lines inside the row.

## Decision

- The name is printed in `span.mt-site-name` inside `a.mt-site-title`.
- The span may take two lines (`-webkit-line-clamp: 2`, line height 1.2, so 2.4em fits in the 4rem row); a word that still does not fit, and the end of a third line, end in an ellipsis (`text-overflow: ellipsis`, words never break inside). The title is no longer `nowrap`.
- Below 64rem the name is one step smaller (15px), so a two-word name such as "modoo.today theme" or "Static Agent Marketplace" shows in full from 390px.
- The breakpoint of the inline nav stays at 64rem.

## Consequences

Every page's header markup gains the span. A site rule that set `white-space` or `text-overflow` on `.mt-site-title` now targets `.mt-site-name`. At 360px a long single word still ends in an ellipsis; the full name stays in the link's text for assistive technology. The core sheet grows by the two rules.
