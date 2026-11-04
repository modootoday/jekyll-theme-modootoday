---
id: adr:modootoday/20261104174901
title: Four-column tables fit the text column by breaking code after the first column
status: active
created: 2026-11-04T17:49:01Z
updated: 2026-11-04T17:49:31Z
rel:
  governs: [_sass/modootoday/components/table, test/system/audit/layout/table-reflow.mjs]
---

# Four-column tables fit the text column by breaking code after the first column

## Context

adr:modootoday/20261103223545 kept code unbroken in every cell of a table with four or more columns and let the table grow to about 9rem per column (`max(100%, 36rem)` for four), scrolling past that. On the API reference the four-column "Component structure" table holds long class chains in its later columns; their unbroken width made the table's minimum 817px, so in the 720px text column at 768 and 1440px it scrolled by 97px and its last column read as cut off. Below 40rem such a table already stacks (adr:modootoday/20261104115652), which is not wanted above 40rem.

Options weighed: widening the doc column for tables (the table of contents column sits beside it at 1440px, and at 768px there is no room); a front-matter switch to drop the table of contents (fixes one page only); shorter cell text (fixes the docs, not sites); letting code break in the later columns with a floor.

## Decision

- In a table with four or more columns, code in the first column still never breaks; code in later cells may break anywhere (`overflow-wrap: anywhere`), and those cells keep a 6rem floor, so the table's minimum width drops below the text column and it lays out at the column width.
- The wider budgets for five and six columns stay; such a table still scrolls where its column is narrower than the budget.
- The docs QA table audit also checks, at 768 and 1440px, that a four-column table on the audited pages does not scroll.

## Consequences

Measured on the API reference through remote rendering with the rule applied: the table is 720px in its 720px column at 768 and 1440px (was 817px, 97px of scrolling), and its tallest cell grows from 16 to 17 lines. Long class names in later cells now wrap mid-name at those widths. Stacking below 40rem and the phone-width rules are unchanged.
