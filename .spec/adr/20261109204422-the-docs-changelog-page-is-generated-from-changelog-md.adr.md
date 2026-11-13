---
id: adr:modootoday/20261109204422
title: "The docs Changelog page is generated from CHANGELOG.md through a releases data file, and only the English page carries the release list"
status: active
created: 2026-11-09T20:44:22Z
updated: 2026-11-13T05:31:22Z
rel:
  governs: [docs/reference/changelog.md, docs/reference/changelog.ko.md, docs/reference/changelog.ja.md, script/docs/releases.rb]
---

# The docs Changelog page is generated from CHANGELOG.md through a releases data file, and only the English page carries the release list

## Context

The docs Changelog page (en, ko, ja) still showed only 1.0.0 six releases later ([[audit:modootoday/20261109200220]] V1). Rule R5 of [[adr:modootoday/20261109200230]] says the page is generated from CHANGELOG.md. The governance research ([[research:modootoday/20261109150011]] B5) proposed a releases data file with a `--check`.

The first version of this decision also put the English release list on the ko and ja pages. An English list on a translated page is read with the wrong voice: a screen reader reads it with the page language's voice, because nothing marks its language. Marking it needs `lang` on the list, which a docs page cannot carry: docs pages must read on GitHub, so they use no kramdown attribute lists and no raw HTML (reverted in d8762f0). The operator decided on 2026-11-13, before the 1.7.0 tag, that translations no longer carry the list.

## Decision

- `script/docs-index` owns the page. It reads the released entries of CHANGELOG.md and writes `docs/_data/releases.yml`: version, date, tag URL, and per section its name, item count and a lead for each item.
- A lead is the item's opening words: links as text, cut outside code at the first sentence end, colon, semicolon or parenthesis, then at a word end within 90 characters.
- Only the English `reference/changelog` page carries the release list made from that file between the page-list markers. `script/docs-index --check`, run by the pre-push hook and by `rake test`, fails when the page or the data file is stale.
- The ko and ja `reference/changelog` pages keep their translated introduction, with no release list and no page-list markers, and link the English Changelog page for the list. `script/docs-index` writes the list into the English page only, and `test/project/docs_index_test.rb` fails when a translation carries release headings or the markers, or does not link the English page.
- The page keeps no authored release text; the full entries stay in CHANGELOG.md, linked from the page.

## Consequences

- Releasing needs no hand edit of the docs Changelog page: running `script/docs-index` after the CHANGELOG entry is dated rewrites it.
- The data file is ready for the changelog feed to read.
- Readers of ko and ja follow one link to the English list, which is read in its own language; a release changes no translation, so it never marks one stale.
