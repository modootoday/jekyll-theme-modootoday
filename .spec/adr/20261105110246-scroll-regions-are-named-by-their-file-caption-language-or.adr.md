---
id: adr:modootoday/20261105110246
title: "Scroll regions are named by their file, caption, language or heading, numbered while names repeat"
status: active
created: 2026-11-05T11:02:46Z
updated: 2026-11-05T11:03:06Z
rel:
  governs: [assets/js/modootoday/content/scroll-region.js]
---

# Scroll regions are named by their file, caption, language or heading, numbered while names repeat

## Context

`content/scroll-region.js` makes an overflowing code block or table wrapper a focusable `role=region`, so keyboard users can scroll it (WCAG 2.1.1). Every code region was named "Code" and every table region "Table", so a page with two overflowing code blocks failed axe best-practice `landmark-unique`, and a screen reader's landmark list showed several identical entries. The 1.5.0 and 1.6.0 reviews found it on several docs pages, mostly at phone widths.

## Decision

- **A name tells the block apart.** The label (`code.label` or `table.label`) is joined with the first of: the `file:` title of the block, the table's `caption` or the enclosing figure's `figcaption` (a chart), the code language (not `plaintext`), else the text of the nearest `h2`-`h4` above it. The join is the new i18n pattern `region.named` (`[label], [name]`; full-width parentheses in ja and zh, the Arabic comma in ar and fa).
- **An ordinal makes it unique.** While two blocks would still share a name, each of them gets a number in page order through `region.nth` (`[name] [n]`).
- **Names are fixed when the page loads**, over every candidate block, not only the ones that overflow now, so a region keeps its name across resizes and between visits at different widths. A table named "Table 1" may therefore be the only region at a wide window.
- **The patterns reach the module** as `data-mt-region-named` and `data-mt-region-nth` on `<html>`, beside the existing `data-mt-code` and `data-mt-table`, and both keys are in all 23 catalogs. An element that already has an `aria-label` keeps it.
- **Budget.** The module grows from 552 to 1,129 bytes gzip; its cap moves from 640 to 1,280 in its own registry row (adr:modootoday/20261104053146).

## Consequences

Landmark lists read like "Code, yaml 2" or "Table, Settings" instead of a column of "Code". Every page's `<html>` gains two attributes, so every page's HTML differs from 1.5.0 by them; nothing else in the markup changes. Code and table regions share one rule, so a page can no longer mix a numbered code block with an identically named table.

## Amendment (1.6.0 audit fixes)

The 1.6.0 usability and visual audit (audit:modootoday/20261105135021) found three faults in the names and tab stops
this decision sets: a nearest heading that only repeats the label gave "Table, Tables 1"; numbers counted blocks that
did not scroll at that width, so a page could expose "Code, ruby 2" with no "Code, ruby 1"; and the static math,
diagram and SVG figure scrollers stayed tab stops when their content fit, with a diagram named by its full alt text.

- A heading equal to the label (ignoring case and a plural s) is left out of the name.
- Numbers count only the regions that exist at the current width, and the names are recomputed when a region appears
  or goes, so "numbered while names repeat" now means repeats among live regions.
- `div.mt-figure-scroll` joins the module and its triggers (`mt-figure-scroll` in the registry row): the HTML keeps it a
  named region for readers without JavaScript, and the module removes the tab stop while the content fits. Diagram
  and SVG figure regions are named by `diagram.label` and the caption, not the alt text.
- **Budget.** The module measures 1,445 bytes gzip (from 1,129): the live-region set, renumbering on resize and the
  figure path. Its cap moves from 1,280 to 1,664, the measured size plus 10% rounded up to 128 bytes
  (adr:modootoday/20261104053146), in its registry row.
