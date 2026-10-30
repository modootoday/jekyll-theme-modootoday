---
id: adr:modootoday/20261030083500
title: Page layouts with optional per-layout CSS bundles
status: active
created: 2026-10-29T23:35:00Z
updated: 2026-10-29T23:35:00Z
rel:
  governs: [_layouts/, _includes/modootoday/pages/, assets/css/, qa/audit/budgets.mjs, lib/modootoday/check/layouts.rb, docs/layouts/shells.md]
---

# Page layouts with optional per-layout CSS bundles

## Context

1.0 ships every layout in the layout research (shells, directory, details, marketing, docs extras, legal, resume, loading states). Core CSS is capped at 32 KiB and core JS at 10 KiB; adding all layouts to core would break both.

## Decision

- Layouts chain onto `default`. A layout or page sets `mt_bundle: <name>` to load `assets/css/modootoday-<name>.css`; `mt_chrome: false` hides header, page meta, pagination and menu script; `mt_main` adds a class to `main`.
- Bundles: `pages` (shells), `directory`, `marketing`, `docs-extra`, `resume`, plus `blog` from the blog branch. Each bundle has its own 8 KiB QA budget; core budgets are unchanged.
- Layouts add no JavaScript. Structured data (schema.org JSON-LD) is printed by Liquid.
- Child layouts render before `default`, so their includes load i18n and the home URL themselves.
- Every layout has a contract in `lib/modootoday/check/`, labels in all 23 catalogs, en/ko/ja docs and demos, and QA pages.

## Consequences

A site that uses no new layout loads no extra CSS. A new layout family adds a bundle, not core bytes.
