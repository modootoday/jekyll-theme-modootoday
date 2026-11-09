---
id: adr:modootoday/20261109204422
title: "The docs Changelog page is generated from CHANGELOG.md through a releases data file, release text stays English in every language"
status: active
created: 2026-11-09T20:44:22Z
updated: 2026-11-09T20:44:42Z
rel:
  governs: [docs/reference/changelog.md]
---

# The docs Changelog page is generated from CHANGELOG.md through a releases data file, release text stays English in every language

## Context

The docs Changelog page (en, ko, ja) still showed only 1.0.0 six releases later ([[audit:modootoday/20261109200220]] V1). Rule R5 of [[adr:modootoday/20261109200230]] says the page is generated from CHANGELOG.md. The governance research ([[research:modootoday/20261109150011]] B5) proposed a releases data file with a `--check`.

## Decision

- `script/docs-index` owns the page. It reads the released entries of CHANGELOG.md and writes `docs/_data/releases.yml`: version, date, tag URL, and per section its name, item count and a lead for each item.
- A lead is the item's opening words: links as text, cut outside code at the first sentence end, colon, semicolon or parenthesis, then at a word end within 90 characters.
- The `reference/changelog` page in every language carries the release list made from that file between the page-list markers. `script/docs-index --check`, run by the pre-push hook and by `rake test`, fails when either is stale.
- The release list stays English in ko and ja, with section names as CHANGELOG.md writes them. The translated page says so. The page-list markers are left out of `source_rev`, so a release does not mark the translations stale.
- The page keeps no authored release text; the full entries stay in CHANGELOG.md, linked from the page.

## Consequences

- Releasing needs no hand edit of the docs Changelog page: running `script/docs-index` after the CHANGELOG entry is dated rewrites it.
- The data file is ready for the planned changelog feed to read.
- Readers of ko and ja see English release leads, which matches the canonical-language rule for release notes.
