---
id: adr:modootoday/20261029204501
title: Public API and deprecation policy
status: superseded
created: 2026-10-29T20:45:01Z
updated: 2026-10-29T23:20:00Z
rel:
  governs: [docs/reference/api.md]
---

# Public API and deprecation policy

## Context

Adopters need to know which names survive minor releases before 1.0 is tagged.

## Decision

The public API is the list on docs/api.md: modootoday: config keys, front matter keys, section c values, code-span prefixes, layout and include names documented for overrides, mt-* classes and --mt-* custom properties, i18n keys, modootoday-check options and exit codes, and the twin and llms.txt URLs. Anything else is internal. From 1.0, removing or changing a public name needs a major release; a name is first marked deprecated in a minor release, listed in CHANGELOG, flagged by modootoday-check where possible, and kept for at least the rest of that major. Before 1.0 (0.x), minor releases may break, but every break is listed in CHANGELOG with an upgrade note. A slot contract for layouts (named override points) is deferred to 1.x. Non-goals: right-to-left layouts, math and Mermaid rendering.

## Consequences

docs/api.md is the reference for what is stable; the upgrade guide lists changes per release.
