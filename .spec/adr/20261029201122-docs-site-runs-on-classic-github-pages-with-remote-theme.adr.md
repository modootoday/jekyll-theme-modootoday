---
id: adr:modootoday/20261029201122
title: Docs site runs on classic GitHub Pages with remote_theme
status: active
created: 2026-10-29T20:11:13Z
updated: 2026-10-29T20:11:20Z
---

# Docs site runs on classic GitHub Pages with remote_theme

## Context

The real user environment is classic Pages (github-pages gem); Jekyll 4 is the other supported stack.

## Decision

The planned dogfooding docs site deploys from a branch with `remote_theme` pinned to a release tag; CI also builds with Jekyll 4 and with `remote_theme` at the pushed commit.

## Consequences

Docs always show the released theme; main previews come from CI builds.
