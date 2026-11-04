---
id: adr:modootoday/20261104195533
title: Card columns follow the section width and fill whole rows
status: active
created: 2026-11-04T19:55:33Z
updated: 2026-11-04T19:55:58Z
rel:
  governs: [_sass/modootoday/components/section/showcase/_card.scss]
---

# Card columns follow the section width and fill whole rows

## Context

`cols: 3` and `cols: 4` on a `c: features` section switched on only when the section was 48rem and 64rem wide. A doc page's text column is 45rem (720px), so inside the docs both fell back to the automatic 16rem grid: two columns. The kitchen sink's "Cards in three columns" and "Cards in four columns" both showed two, a card saying "Four across on wide screens" was false, and the home page's three "Why" cards left the third one alone on a row.

Options weighed for `cols: 4` in a 45rem column: four tracks of about 10.5rem with the 1.5rem card padding leave about 7.5rem of text per card, roughly 15 characters per line at 14px, which wraps every description and most Korean titles; three tracks leave a lone fourth card; two by two keeps every row full.

## Decision

- The count follows the section's own width (container queries on `.mt-c-features`), never the screen.
- `cols: 2|3|4` start at one column and add a track only when every track can be 16rem wide (n tracks of 16rem plus 1rem gaps), the floor the docs QA card grid audit holds every card to: two from 33rem, `cols: 3` three from 50rem, `cols: 4` four from 67rem (two by two before that).
- In two columns, an odd last card of `cols: 3` spans the row, so no row ends with a lone half-width card.
- So a 45rem text column shows `cols: 3` as two plus one full-width card and `cols: 4` as two by two; a section 50rem or wider (the docs home without a TOC from 80rem, a marketing or wide layout) shows three across.
- Amended for 1.5.0 (docs QA, round 2): three tracks from 40rem left cards under 16rem (about 12.7rem) in the text column at 1024px, which the card grid audit failed on the home page, Components and the kitchen sink.
- A section without `cols:` keeps the automatic 16rem grid.

## Consequences

The docs say what the reader sees, no card is narrower than 16rem, and no row ends with a lone half-width card. Between 33rem and 50rem `cols: 3` shows two plus a full-width card. The card sheet grows by a few bytes, within its cap.
