---
id: adr:modootoday/20261103053804
title: Nested structured-data nodes are checked as warnings in 1.6 and as errors from 2.0
status: active
created: 2026-11-03T05:38:04Z
updated: 2026-11-03T05:38:24Z
rel:
  governs: [lib/modootoday/check/build/structured_data.rb]
---

# Nested structured-data nodes are checked as warnings in 1.6 and as errors from 2.0

## Context

The structured-data rule checks the nodes of `@graph` and the nodes inside arrays. It does not check a single nested object such as `acceptedAnswer`, `offers` or `hiringOrganization`. Checking those against the same required and recommended properties would catch real omissions, for example an event `offers` without a price. It would also turn sites that pass today into failing builds.

## Decision

- 1.6.0 checks every nested typed object with the rules of its type. A missing required property there is a warning, not an error. `--schema-recommended` keeps covering recommended properties.
- 2.0.0 makes a missing required property in a nested object an error, as it already is for top-level nodes. The 2.0 upgrade notes list it.

## Consequences

Sites see the new findings one minor release before they can fail a build. The checker keeps one rule table for top-level and nested nodes; only the severity differs, and only until 2.0.
