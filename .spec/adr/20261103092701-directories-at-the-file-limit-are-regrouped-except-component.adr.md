---
id: adr:modootoday/20261103092701
title: "Directories at the file limit are regrouped, except component partials whose paths are API"
status: active
created: 2026-11-03T09:27:01Z
updated: 2026-11-03T09:27:23Z
rel:
  governs: [lib/modootoday/check/config/keys, test/layouts, test/support, _sass/modootoday/components/core/inline]
  depends_on: [adr:modootoday/20261103002031]
---

# Directories at the file limit are regrouped, except component partials whose paths are API

## Context

`test/project/layout_test.rb` allows at most 12 tracked files per directory. Three directories held exactly 12, so the next file would break the limit: `lib/modootoday/check/config/keys`, `test/layouts` and `_sass/modootoday/components/core/inline`. A directory at its limit is a structural finding now, not when it overflows.

## Decision

- `lib/modootoday/check/config/keys/` is grouped by feature: `appearance/` (colour scheme, chrome, components, tokens, on/off switches), `pages/` (twins, aliases and records, content, search, languages, edit URL) and `serving/` (asset delivery and CSP). `config/keys.rb` keeps the same load order, which is the report order; the registered key order is unchanged.
- `test/layouts/` is grouped into `families/` (detail, directory, docs-extra, marketing, page shells) and `features/` (SVG figures, hero, lists, ref links, renderers, reveal and badges). Its site builder, which `test/theme/assets/` also uses, moves to `test/support/layout_site.rb`, where Ruby keeps test-only support.
- `_sass/modootoday/components/core/inline/` stays as it is. Every partial in it is imported through the load path (`_sass/modootoday.scss`, and `assets/css/modootoday.scss` through `mt_core_partials`), so under adr:modootoday/20261103002031 a site can shadow it at that path. Moving one would silently stop a site's shadow from applying, which is a change to the public API. A new core inline partial goes into a new sibling group under `components/core/` instead, which needs no move.

## Consequences

The checker's output and every test result are unchanged; only paths of internal Ruby files and tests move. The inline partial directory keeps no headroom by design, and the rule for its next partial is recorded here.
