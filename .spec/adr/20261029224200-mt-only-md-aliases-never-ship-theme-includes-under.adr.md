---
id: adr:modootoday/20261029224200
title: "mt-* only: md-* aliases never ship; theme includes under modootoday/"
status: active
created: 2026-10-29T22:42:00Z
updated: 2026-10-29T22:42:00Z
rel:
  supersedes: [adr:modootoday/20261029204442]
---

# mt-* only: md-* aliases never ship; theme includes under modootoday/

## Context

The plan kept `md-*` classes and `--md-*` properties as deprecated aliases through 1.x and removed them in 2.0, and the theme's own includes kept `_includes/md-*.html` and `assets/js/modootoday/tabs.js` as frozen paths. Nothing has been released, so no site depends on a published name. The owner decided (2026-10-30) that work deferred to 2.0 is done inside 1.0, and that the API is not frozen before the first release.

## Decision

- 1.0.0 ships only `mt-*` classes and `--mt-*` custom properties. The alias map, `$mt-md-aliases`, the twin `md-*` classes in the markup and the checker's alias warnings are removed, not deprecated. The skip link targets `#mt-main`.
- Theme includes and scripts follow the context directory: `_includes/modootoday/markdown/components.html`, `sections.html`, `raw-body.html`, `llms-pages.html` and `assets/js/modootoday/tabs.js`. Tab ids are `mt-tabs-*`.
- The content rule set keeps its name `md-components v1` (it names Markdown rules, not a CSS prefix).
- The CHANGELOG and docs carry no deprecation notice and the upgrade guide has no md-to-mt section.

## Consequences

The bundle is smaller and has one name per token. Sites built from an unreleased commit that used `md-*` names or included `md-*.html` must rename them before moving to 1.0.0. The deprecation policy applies from 1.0.0 on.
