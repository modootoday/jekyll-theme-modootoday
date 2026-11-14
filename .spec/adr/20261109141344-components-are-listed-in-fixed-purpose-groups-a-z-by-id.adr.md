---
id: adr:modootoday/20261109141344
title: "Components are listed in fixed purpose groups, A-Z by id inside each, in every language"
status: superseded
created: 2026-11-09T14:13:44Z
updated: 2026-11-14T09:11:30Z
rel:
  governs: [docs/_data/components.yml, docs/_data/component_groups.yml, test/system/docs/order.rb]
  depends_on: [adr:modootoday/20261109124854]
---

# Components are listed in fixed purpose groups, A-Z by id inside each, in every language

## Context

The components index, the kitchen sinks, `components.yml` and the checker's messages each list the components in a different order, so a reader cannot predict where one is and a new component has no obvious place. Reference design systems order by purpose and then alphabetically. The maintainer decided the order on 2026-11-05, to ship as a 1.7.0 item right after the 1.6.0 tag. The recipes sidebar runs one entry over the information architecture cap until it is regrouped ([[adr:modootoday/20261109124854]]).

## Decision

- **Groups, in this fixed order:** Text and inline, Blocks, Media, Data, Disclosure and sequence, Page sections, Site chrome.
- **Inside a group:** A-Z by the component's English id. Korean, Japanese and every other language use the same order, so an index never reorders by translated name.
- **One canonical list:** a docs data file names each component's group; a test fails when a component is missing from it, sits in no group, or appears out of order on the components index.
- `components.yml` and the checker's component lists go A-Z by id. The asset registry keeps its own order (it is a delivery table, not a reading list). The kitchen sinks follow the groups.
- The same item regroups the recipes sidebar to 12 entries or fewer with every published URL kept, and removes the recipes exception from the docs structure check.

## Consequences

- A reader finds a component by purpose first and by name second, in any language.
- Adding a component means choosing its group in one file; the test catches the rest.
- The recipes exception in the docs structure check exists only until this item lands.
- The canonical list is `docs/_data/component_groups.yml`, checked by `test/system/docs/order.rb` (in `rake test` and the pre-push hook). Its ids are the `modootoday.components` names plus four docs topics with their own section on the components pages (`typography`, `icons`, `language-switcher`, `posts`). A page section names its component by `c:` (the registry maps `features` to `card`) or, without `c:`, by its name: the id or `<id>-<variant>`. The plain sections were renamed to fit (`alerts` to `callout`, `badges` to `badge`, `keyboard` to `kbd`, `tables` to `table`, `embeds` to `embed`, `navigation` to `nav`, `status` to `badge-legend`, `charts` to `chart`). Pages with titles for every group (en, ko, ja) carry a `group-<id>` heading section before each group; the Arabic RTL sample keeps the order without headings.
- Assignments that are not obvious:

| Component | Group | Why |
| --- | --- | --- |
| `loading`, `progress` | Text and inline | written as code spans inside a paragraph |
| `lists`, `typography` | Text and inline | styles of running text, not separate blocks |
| `callout` | Blocks | a GitHub alert stands between paragraphs |
| `filetree`, `quote` | Blocks | single blocks in running text, although written as `c:` sections |
| `code-copy`, `terminal` | Blocks | they decorate a code block |
| `gallery`, `widget` | Media | pictures and embedded elements, although written as `c:` sections |
| `diagram`, `figure-svg`, `visual` | Media | rendered pictures |
| `chart`, `params` | Data | both are drawn from a table |
| `hero`, `bleed`, `reveal` | Page sections | options of a page band |
| `banner`, `page-actions`, `showcase`, `sidebar`, `toc` | Site chrome | added by the layouts, never written in a page |
| `icons`, `language-switcher`, `posts` | Site chrome | docs topics about the header, footer and post layouts |
