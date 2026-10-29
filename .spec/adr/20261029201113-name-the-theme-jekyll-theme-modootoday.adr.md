---
id: adr:modootoday/20261029201113
title: Name the theme jekyll-theme-modootoday
status: active
created: 2026-10-29T20:11:13Z
updated: 2026-10-29T20:11:20Z
---

# Name the theme jekyll-theme-modootoday

## Context

RubyGems/Jekyll themes are discovered by the `jekyll-theme-` prefix; the repo lives under the modootoday GitHub org.

## Decision

Gem and repository name `jekyll-theme-modootoday`; executable `modootoday-check`; config namespace `modootoday:`.

## Consequences

Consumers use `theme: jekyll-theme-modootoday` or `remote_theme: modootoday/jekyll-theme-modootoday@<tag>`. Renaming later breaks both.
