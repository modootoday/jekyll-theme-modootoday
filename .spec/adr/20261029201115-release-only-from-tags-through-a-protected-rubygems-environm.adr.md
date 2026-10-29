---
id: adr:modootoday/20261029201115
title: Release only from tags through a protected rubygems environment
status: active
created: 2026-10-29T20:11:13Z
updated: 2026-10-29T20:11:20Z
rel:
  governs: [.github/workflows]
---

# Release only from tags through a protected rubygems environment

## Context

Publishing a gem is irreversible (yanked versions cannot be reused). RubyGems supports OIDC trusted publishing from GitHub Actions.

## Decision

`.github/workflows/release.yml` runs only on `v*` tags, in the `rubygems` environment with a required reviewer, with `id-token: write` and `rubygems/release-gem@v1` (trusted publishing, no API key). Creating a tag or publishing needs the owner's explicit approval; agents never tag or publish on their own.

## Consequences

main can move freely; a release is a deliberate two-step act (tag, then reviewer approval).
