---
id: adr:modootoday/20261029223219
title: "Version badges (since:) start in 1.1, not in 1.0"
status: draft
created: 2026-10-29T22:32:19Z
updated: 2026-10-29T22:32:19Z
---

# Version badges (since:) start in 1.1, not in 1.0

## Context

`since:<version>` code spans rendered a "Since" badge. 1.0.0 is the first release, so every feature would carry the same `since:1.0` badge, which tells readers nothing.

## Decision

- 1.0 has no `since:` badge: the theme does not render it, the `.mt-badge-since` class and the `badge.since` i18n key are gone, and `modootoday-check` reports any `since:` code span as an error.
- `since:` is introduced from 1.1 onward, as an additive change, and is used only for features added after 1.0.

## Consequences

- Docs and kitchen sinks show status and tag badges only.
- Adding `since:` in 1.1 is backward compatible: the checker error becomes a value check.
