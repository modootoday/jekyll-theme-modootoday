---
id: adr:modootoday/20261103091952
title: The docs language list is generated from i18n/languages.yml
status: active
created: 2026-11-03T09:19:52Z
updated: 2026-11-03T09:20:04Z
rel:
  governs: [script/i18n-build]
---

# The docs language list is generated from i18n/languages.yml

## Context

The docs site reads its language menu from `docs/_data/languages.yml`, and the theme's catalogs are built from `i18n/languages.yml`. The docs site loads the theme as a remote theme, and Jekyll reads `site.data` only from the site's own `_data/`, so the docs need a copy. The copy was kept by hand, byte for byte, with nothing to catch drift.

## Decision

- `i18n/languages.yml` is the one owner of the language list.
- `script/i18n-build` writes `docs/_data/languages.yml` as that file with a one-line "generated, do not edit" header, next to the Liquid catalogs it already writes.
- `script/i18n-build --check`, which CI runs, reports the docs copy as out of date like any other generated file.

## Consequences

Adding a language means editing `i18n/languages.yml` and running `script/i18n-build` (TRANSLATING.md). The header is a YAML comment, so the data and the built docs are unchanged.
