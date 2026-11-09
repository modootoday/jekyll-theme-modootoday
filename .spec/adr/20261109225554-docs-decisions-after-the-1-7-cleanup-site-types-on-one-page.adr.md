---
id: adr:modootoday/20261109225554
title: "Docs decisions after the 1.7 cleanup: site types on one page, one layout-doc pattern, RULES and README.ja published, callout rules, report checks made blocking"
status: active
created: 2026-11-09T22:55:54Z
updated: 2026-11-09T22:56:13Z
rel:
  governs: [docs]
  depends_on: [adr:modootoday/20261109200230, audit:modootoday/20261109200220]
---

# Docs decisions after the 1.7 cleanup: site types on one page, one layout-doc pattern, RULES and README.ja published, callout rules, report checks made blocking

## Context

The cleanup of [[audit:modootoday/20261109200220]] under [[adr:modootoday/20261109200230]] fixed 37 of 52 findings. It left seven findings that needed a decision (D6, N2, N3, N8, D8, P3, F5) and two rule checks in report mode: description length and front matter key order. It also made three calls the maintainer was asked to confirm. The maintainer took every recommendation below on 2026-11-09.

## Decision

- **D6 Site types on one page.** The six site-type recipes (product, company, documentation, personal, community, system) become one "Site types" recipe with a section each. Their old URLs get redirect stubs through `moved_from`, like the figure recipes. This removes the six index-only groups that R7 reports.
- **N2 The components page stays one page.** Its anchors are linked from outside and cannot be redirected. The seven group headings already give it structure. A future split needs its own ADR.
- **N3 One layout-doc pattern.** Each layout group's index holds a front matter reference table for its layouts and links each layout's demo. A separate reference page exists only for a layout whose keys do not fit the table.
- **N8 Guides keep their URLs.** There is no directory split. Navigation order puts the getting-started guides (install, configuration, upgrade) first and the topic guides after them.
- **D8 RULES.md is published** as a docs reference page generated from RULES.md, the single source, with a `--check`.
- **P3 README.ja.md is added**, matching the en, ko and ja docs policy. The README parity test covers all three.
- **F5 Callout usage rules.** The glossary gets one line per GitHub alert type, saying when to use NOTE, TIP, IMPORTANT, WARNING and CAUTION. A lint reports unknown types and flags a page with more than three callouts.
- **Report checks become blocking.** The existing descriptions are rewritten to 70–160 characters (202 pages). Front matter key order is fixed by a script that rewrites the order without changing values (192 pages). Then both R3 checks block.
- **Confirmed:**
  - the event, events and api demos set `twin: false`;
  - Tags and Categories are out of the Reference sidebar;
  - the eight keys the checker now validates fail on wrong values.

## Consequences

- The recipes sidebar shrinks further, and no group directory holds only an index.
- Layout docs read the same way in every group.
- RULES.md and README.ja.md cannot drift from their sources.
- Every docs rule from adr:modootoday/20261109200230 is blocking once this lands, except R4 staleness, which stays report-only until 1.8's version-pin normalization.
