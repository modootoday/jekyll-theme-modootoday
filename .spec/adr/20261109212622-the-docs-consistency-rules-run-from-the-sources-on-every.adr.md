---
id: adr:modootoday/20261109212622
title: "The docs consistency rules run from the sources on every push, blocking where the pages already pass and reported elsewhere"
status: active
created: 2026-11-09T21:26:22Z
updated: 2026-11-09T21:26:36Z
rel:
  governs: [test/system/docs]
  depends_on: [adr:modootoday/20261109200230]
---

# The docs consistency rules run from the sources on every push, blocking where the pages already pass and reported elsewhere

## Context

[[adr:modootoday/20261109200230]] made rules R1 to R8 canonical and said each check lands in report mode where the pages would fail it, and blocks once the cleanup has cleared them. The 1.7.0 cleanup of [[audit:modootoday/20261109200220]] cleared most of them; some need a rewrite of many pages or a maintainer decision first.

## Decision

- `test/system/docs/rules.rb` (one file per rule under `rules/`) checks R1, R3, R5, R7 and R8 from the sources, with no build. `test/system/docs/registries.rb` checks R6. Both run in `rake test` and in the pre-push hook. R2 runs in the i18n lint (`avoid.en` in `i18n/glossary.yml`), R4 in `--i18n-pages` as before.
- Blocking at 1.7.0: no repeated paragraph over 200 characters, a topic of `docs/_data/topics.yml` links its canonical page, H1 equals `title`, a description never repeats the title, `nav_title` only as a shorter form (or the initials) of the title and only where the English page has one, unique `nav_order` in a sidebar group, layout demos set `twin:`, no version in a heading and no past version in running text outside Migrate and upgrade and the Changelog, no orphan page, sample-site pages out of the docs navigation, relative links between docs pages, a guide or recipe links another docs page, and every R6 doctest.
- Reported, not blocking: descriptions of 70 to 160 characters (about 200 pages are shorter), the front matter key order (about 190 pages differ), sidebar groups of 11 or more entries (a warning by design), and group directories that hold only an index (the six site-type recipes, which [[adr:modootoday/20261109192542]] keeps).
- Exemptions written into the rules: a layout demo's H1 and nav label are sample content; a home page's H1 is its hero headline; a page in another language than its file's (the right-to-left samples) keeps an English title; an error page keeps root-absolute links, since it is served at any URL.
- A reported rule becomes blocking in the change that clears its last finding, by moving its name into `BLOCKING`.

## Consequences

- A docs change that breaks a blocking rule fails before it is pushed; the report lines show what is left of the others.
- The topic map starts small (twins, token bridge, command line, stacks, layout list, showcase) and grows as topics get one canonical page.
