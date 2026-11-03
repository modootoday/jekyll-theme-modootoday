---
id: adr:modootoday/20261103205956
title: "Doc columns are the sidebar, the measure and the TOC from layout hooks, and the page meta follows the text column"
status: active
created: 2026-11-03T20:59:56Z
updated: 2026-11-03T21:00:12Z
rel:
  governs: [_sass/modootoday/components/doc, _sass/modootoday/registry]
---

# Doc columns are the sidebar, the measure and the TOC from layout hooks, and the page meta follows the text column

## Context

Doc pages used fixed column widths in two files: a 12rem sidebar with a 3rem gap from 64rem and 12rem / 2.5rem from 80rem, a 14rem TOC with a 3.5rem gap, and the page meta, pager and back-to-top link pushed by hand-kept offsets (15rem, 14.5rem) that did not match the column. The flat base asks for 288px / 45rem / 240px columns with a 32px gap in a wider docs frame, and adr:modootoday/20261103191401 decided that such layout knobs are hooks read through `var()` fallbacks, with their defaults in `registry/_hooks.scss`.

## Decision

- `registry/_hooks.scss` holds `$mt-hooks` with `sidebar-width` 18rem, `toc-width` 15rem, `doc-gap` 2rem and `doc-container` 90rem. `mt-hook(<name>)` returns `var(--mt-<name>, <default>)` and fails the build for a name the map lacks. `_core.scss` and `_sheet.scss` import the map; it has no output.
- From 64rem a page with a sidebar is `sidebar-width` + `measure`, and from 80rem `sidebar-width` + `measure` + `toc-width` (the text column stays at the measure; it does not take the leftover space). A TOC-only page is `measure` + `toc-width`. Every gap is `doc-gap`.
- Everything after the doc layout (page meta, pager, back-to-top) starts at `sidebar-width + doc-gap`, the same formula at both breakpoints, with the measure as its width.
- A page with a sidebar widens the header, main and footer to `doc-container` (`.mt-body:has(.mt-has-sidebar)`).
- A doc page without TOC or sidebar centres the measure (was 52rem).
- Sidebar items are 14/20 in rows of 32px with a filled current item at weight 500; group titles are 12/16 at 500, muted, without capitals or tracking, 1.5rem apart. TOC items are 14/20 in rows of 28px, its title 14/20 at 500. TOC links draw their focus ring inside (`outline-offset: -2px`), since the sticky column scrolls. Every hero clears the page-actions float.
- The theme never declares a hook: the CSS test fails on `--mt-<hook>:` in any sheet and on a fallback other than the map's value, the portability check and the `modootoday-check` build check report only a `var()` without a fallback as undefined, and the Customize guide's hooks table (en, ko, ja) must list the map.

## Consequences

The docs frame is wider on large screens and the TOC appears from 80rem with a sidebar, from 64rem without. Sites change the columns with one custom property, without beating any theme selector. The registry later generates `$mt-hooks` and adds the other hooks to it with their first user.
