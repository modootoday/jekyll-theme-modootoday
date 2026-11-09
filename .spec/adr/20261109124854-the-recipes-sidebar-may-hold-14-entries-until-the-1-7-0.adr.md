---
id: adr:modootoday/20261109124854
title: The recipes sidebar may hold 14 entries until the 1.7.0 ordering item regroups it
status: superseded
created: 2026-11-09T12:48:54Z
updated: 2026-11-09T19:26:21Z
rel:
  governs: [test/system/docs/structure.rb]
  depends_on: [adr:modootoday/20261030083000]
---

# The recipes sidebar may hold 14 entries until the 1.7.0 ordering item regroups it

## Context

[[adr:modootoday/20261030083000]] caps every sidebar group at 12 entries and splits a group that would pass it. The 1.6.0 Charts and Widgets recipes bring the recipes section to 13 entries in every language: seven single recipes and six site groups (product, company, documentation, personal, community, system). The docs structure check found it only on the 1.6.0 release check, because the docs QA job runs on manual dispatch.

Splitting now means moving pages. The docs site has no redirects, so a move breaks published URLs: grouping the figure recipes moves Math and diagrams (public since before 1.5.0), and grouping the site recipes moves six URLs public since 1.5.0. The 1.7.0 component ordering item already reworks how the docs order and group their lists.

## Decision

- The recipes section may hold at most 14 sidebar entries; every other group keeps the cap of 12. The check names the exception by section (`ENTRY_LIMITS` in `test/system/docs/structure.rb`).
- No page moves in 1.6.0.
- The 1.7.0 component ordering item regroups the recipes sidebar to 12 or fewer, with the old URLs kept, and removes the exception.

## Consequences

- 1.6.0 ships with the published recipe URLs unchanged.
- The recipes sidebar shows one entry more than the IA cap until 1.7.0; a 15th recipe still fails the check.
