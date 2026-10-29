---
id: adr:modootoday/20261029201117
title: "Alerts top-level only; ## inside alerts, quotes and lists is an error"
status: draft
created: 2026-10-29T20:11:13Z
updated: 2026-10-29T20:11:13Z
rel:
  governs: [_includes]
---

# Alerts top-level only; ## inside alerts, quotes and lists is an error

## Context

Measured on GitHub's renderer, kramdown and CommonMark parsers: `> [!TYPE]` is a GitHub extension outside the GFM spec and GitHub renders only top-level alerts. Sections split on top-level `##` only.

## Decision

Accept any-case types, standalone `[!TYPE]` paragraphs and trailing-space `<br />`; split sections only on top-level h2; nested alerts and `##` inside quotes/alerts/list items, setext, indented or commented `##` are checker errors with messages that point to `###`.

## Consequences

Authors get a clear error instead of silently broken sections; v1 rules stay draft until sign-off.
