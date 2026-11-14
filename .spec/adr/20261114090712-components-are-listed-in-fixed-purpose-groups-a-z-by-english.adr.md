---
id: adr:modootoday/20261114090712
title: "Components are listed in fixed purpose groups, A-Z by English title inside each, in every language"
status: active
created: 2026-11-14T09:07:12Z
updated: 2026-11-14T09:11:30Z
rel:
  governs: [docs/_data/component_groups.yml, docs/_data/components.yml, test/system/docs/order.rb, docs/components]
  supersedes: [adr:modootoday/20261109141344]
---

# Components are listed in fixed purpose groups, A-Z by English title inside each, in every language

## Context

[[adr:modootoday/20261109141344]] put the components in seven purpose groups and sorted them A-Z by component id inside each group. On the Components page a reader sees titles, not ids, so that order reads as unsorted: Buttons (id `cta`) came after Cards (id `card`), and Status legend (a `badge` section) came before Keyboard keys. The maintainer decided on 2026-11-14, before the 1.7.1 release, to sort by the title the page shows.

## Decision

- **Groups, unchanged and in the same fixed order:** Text and inline, Blocks, Media, Data, Disclosure and sequence, Page sections, Site chrome.
- **Inside a group:** A-Z by the English title as shown on the Components page, compared without case. A component with several sections (variants) places each section by its own heading.
- **Every other language** uses the English page's order: a translated page places each section by the English heading of the same section name. An index never reorders by translated title.
- **One canonical list:** `docs/_data/component_groups.yml` maps each component id to its English title inside its group, in title order. The title is the heading of the component's first section on the English Components page; a component without a section there gets a short title of its own.
- **Lookup tables keep id order:** `components.yml` and the checker's component lists stay A-Z by id, since they are looked up by id, not read in order. The asset registry keeps its own order.

## Consequences

- The kitchen sinks follow the same rule; the Arabic RTL sample, which has no group headings, keeps the group order and the English title order inside it.
- `test/system/docs/order.rb` (in `rake test` and the pre-push hook) fails when a group's titles are out of order, a title differs from the first section heading of its component, an English page's headings are out of order inside a group, or a translated page differs from the English order. The previous id order fails it.
- Variant headings are written so that A-Z reads naturally: the card variants say "Cards in 2 columns", "3" and "4", as the Korean and Japanese headings already did.
- Adding a component means choosing its group and title in one file; renaming a section heading can move it, and the test says where.
- The group assignments and the topic ids (`typography`, `icons`, `language-switcher`, `posts`) of [[adr:modootoday/20261109141344]] are unchanged.
