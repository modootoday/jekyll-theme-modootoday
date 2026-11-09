---
id: adr:modootoday/20261109141344
title: "Components are listed in fixed purpose groups, A-Z by id inside each, in every language"
status: active
created: 2026-11-09T14:13:44Z
updated: 2026-11-09T14:14:01Z
rel:
  governs: [docs/_data/components.yml]
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
