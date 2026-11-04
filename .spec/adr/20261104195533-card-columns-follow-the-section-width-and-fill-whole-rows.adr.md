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
- `cols: 2|3|4` start at one column; `cols: 2` is two from 30rem, `cols: 3` three from 40rem, `cols: 4` two by two from 30rem and four from 52rem.
- So a 45rem text column shows `cols: 3` as three across and `cols: 4` as two by two; a wider section (a page without a TOC beside the text, a marketing or wide layout) shows four.
- A section without `cols:` keeps the automatic 16rem grid.

## Consequences

The docs say what the reader sees, and no row in the docs ends with a lone card. Between 30rem and 40rem `cols: 3` stays one column rather than leaving a lone third card. The card sheet grows by a few bytes, within its cap.
