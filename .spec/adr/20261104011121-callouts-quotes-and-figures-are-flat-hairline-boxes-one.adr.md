---
id: adr:modootoday/20261104011121
title: "Callouts, quotes and figures are flat: hairline boxes, one quote rule and the illustration tag above the art"
status: active
created: 2026-11-04T01:11:21Z
updated: 2026-11-04T01:12:42Z
rel:
  governs: [_sass/modootoday/components/core/inline/_callout.scss, _sass/modootoday/components/core/inline/_figure.scss, _sass/modootoday/components/core/inline/_embed.scss, _sass/modootoday/components/section/showcase/_quote.scss, _sass/modootoday/base/_prose.scss]
---

# Callouts, quotes and figures are flat: hairline boxes, one quote rule and the illustration tag above the art

## Context

The flat base style (10g) turned the callout stripe and tint off in its first commit, but callouts still used the old padding, gap and weight, the body quote had a 3px rule, a `c: quote` section was a filled card, figures and embeds had 12px corners, and the `.mt-illustration-tag` badge was positioned over the drawing, where it covered the art (visual audit finding: the illustration tag overlaps the art). The reference specification for these parts: callout 1px border, radius 8, padding 16, a 16px icon with an 8px gap, the type colour on the icon and title only; flat quotes; figures radius 8 with a 1px border and captions in muted 14/20.

## Decision

- Callout: padding 1rem, margin 1.5rem 0, title row 14/20 at weight 600 with a .5rem gap and .25rem below it. The type colour stays on `--mt-callout-accent`, read only by the title (and its `currentColor` icon). No fill and no stripe. The title row stays a full-width flex row, so the icon sits at the start edge and mirrors in right-to-left pages (the RTL audit judges the icon position).
- The news correction note gets `mt-callout-warning`, so its title takes the warning colour its `data-variant` already named.
- Quotes: one rule style. A body `blockquote` has a 2px start rule in `border`, padding 0 1rem, margin 1.5rem 0. A `c: quote` figure drops the card (border box, radius and `card` fill) and uses the same 2px start rule with 1.5rem start padding, the quote at 18/28 in `foreground` and the attribution at 14/20, weight 500, muted.
- Figures: images, SVG figure scroll frames and embeds use `radius` (8px) with the 1px border; captions are 14/20 muted, still centred.
- Illustrations: `.mt-illustration-tag` is static, a `display: table` pill above the art (12/16, muted text, hairline border, no fill), so it never covers the drawing. The figure keeps `position: relative` for sites that place their own children in it.
- `hr` margin 3rem (8px grid).

## Consequences

The look of every page with a callout, quote, figure, embed or illustration changes (kitchen sink, components, configuration, API, legal, posts). Forced colours keep every edge (borders only, no fills), right-to-left pages mirror through logical properties, and nothing animates. `test/theme/css_test.rb` pins the rules. The decor dots of CMP-02 are left to the components commit.
