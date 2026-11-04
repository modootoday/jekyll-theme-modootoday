---
id: adr:modootoday/20261104011122
title: "Callout, figure and embed rules leave the core sheet for a probed content sheet and keep their partial paths"
status: active
created: 2026-11-04T01:11:21Z
updated: 2026-11-04T06:19:30Z
rel:
  depends_on: [adr:modootoday/20261103092701, adr:modootoday/20261103223545]
  governs: [_includes/modootoday/assets/registry.html, _includes/modootoday/config.html, assets/css/modootoday.scss, assets/css/modootoday/content/inline.scss]
---

# Callout, figure and embed rules leave the core sheet for a probed content sheet and keep their partial paths

## Context

The core sheet is linked by every page and has a fixed budget (27,648 bytes on the Pages builder), and the operator asked that features stop competing for it: rules a page does not need go to context sheets that a registry probe links. Callouts, figures, illustrations and embeds appear only on some pages, but their partials sit in `components/core/inline/`, a directory whose paths are a shadowing API (adr:modootoday/20261103092701): moving a file would silently stop a site's shadow from applying.

## Decision

- A new context sheet `assets/css/modootoday/content.css` holds the callout, figure (with `.mt-illustration`) and embed rules. Its rows in `assets/registry.html` probe the rendered body for `class="mt-callout`, `class="mt-figure`, `mt-illustration` and `class="mt-embed`, and are placed before the `figure` row, so the SVG figure sheet still comes after the base figure rules.
- The partials stay at `components/core/inline/_{callout,figure,embed}.scss`. A registry part may now be a path under `components/` (it has a slash); `modootoday.css: bundle` imports such a part from that path, and `content.scss` imports the parts of its own row, so the list has one owner (the registry row). `mt_core_partials` drops the three names.
- One sheet for the three, not one each: they are small, often appear together, and `assets/css/modootoday/` reaches its 12-file limit with this sheet (the regroup by context is a tracked follow-up of 10g).
- Body `blockquote` and `hr` stay in `base/_prose.scss` in the core: they style plain Markdown elements on any page, cost about 0.1 KB, and a callout is a `blockquote` whose base rules must already apply before the content sheet loads.
- No script is added.

## Consequences

Pages without these components load less CSS; pages with them load one more small sheet. A site that narrows `modootoday.components` gets only the named parts in the sheet. The probe test pins which pages link `content.css`, `test/project/component_names_test.rb` checks that a path part names an existing partial, and `test/system/audit/config.mjs` budgets the sheet (measured plus about 10%).
