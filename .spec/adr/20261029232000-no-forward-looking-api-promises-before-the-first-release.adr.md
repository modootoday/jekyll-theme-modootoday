---
id: adr:modootoday/20261029232000
title: No forward-looking API promises before the first release
status: active
created: 2026-10-29T23:20:00Z
updated: 2026-10-29T23:20:00Z
rel:
  supersedes: [adr:modootoday/20261029211900, adr:modootoday/20261029204501]
  governs: [docs/reference/api.md, RULES.md, CHANGELOG.md, docs/guides/upgrade.md, docs/reference/roadmap.md]
---

# No forward-looking API promises before the first release

## Context

The docs promised a frozen 1.0 API, a deprecation policy, and that nothing would be removed before 2.0. The owner decided (2026-10-30) that the API keeps improving until bugs are fixed, nothing is deferred to 2.0, and 1.0.0 is released as soon as the roadmap is done.

## Decision

- Public docs, README, RULES and the CHANGELOG make no promise about 1.x, 2.0, freezing or deprecation. The public API page lists the documented names; changes are listed in the CHANGELOG.
- `md-components v1` stays the name of the Markdown rules standard, not a version promise.
- The upgrade guide's verification step is `modootoday-check --strict`.
- Rules v1 final and "1.0 is the complete roadmap" from the superseded ADR still hold.

## Consequences

Any future compatibility policy is a separate decision recorded when it is made.
