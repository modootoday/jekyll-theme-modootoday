---
id: adr:modootoday/20261103071902
title: Docs keep authored pages and translations side by side; tool output lives under generated/
status: active
created: 2026-11-03T07:19:02Z
updated: 2026-11-03T07:19:22Z
rel:
  governs: [docs/_config.yml]
---

# Docs keep authored pages and translations side by side; tool output lives under generated/

## Context

The documentation site's top level holds 35 directories, and 23 of them are languages. Only two of those languages (ko and ja) translate the site. They mirror the English tree page for page, while the other 21 hold a home page and its generated files. A page's language comes from its directory. Generated files sit between the authored pages in every content directory: 149 Markdown twin stubs, plus `llms.txt` and `llms-full.txt` per language.

As a result, an English page and its translations live in different trees, and TRANSLATING.md asks for both to change together. Half of what a contributor sees in a content directory is tool output they must not edit.

The classic GitHub Pages build has no plugins, so it cannot derive a URL from a file name such as `install.ko.md` (`:basename` keeps `install.ko`). Moving translations into a collection is not an option either: collection documents are not in `site.pages`, which the theme reads for navigation, twins and llms.

## Decision

- **Translations sit beside their source.** For example `guides/install.md`, `guides/install.ko.md` and `guides/install.ja.md`.
  - Each translation carries `lang`, `permalink` (the URL it has today) and `source_rev` (a hash of the source it was translated from).
  - The docs generator writes these fields, and the checker verifies them. The checker reports missing, stale (source changed since `source_rev`) and orphaned translations.
- **Languages that translate only the home page keep it under `home/`** (`home/index.vi.md`, ...). Their URLs stay `/vi/`, ...
- **Everything a tool writes goes under `generated/`.** That means twin stubs and per-language `llms*.txt`, each with an explicit permalink so it keeps its URL. Contributors do not edit `generated/`; the generator rewrites it and `--check` fails when it is stale.
- **Acceptance:** every built URL stays the same, and the built site is byte-identical before and after the move, on Jekyll 4 and on the classic builder.
- **The work is done in two steps, both before the 1.5.0 release checks:**
  1. Move the generated files to `generated/`.
  2. Move translations beside their sources and add `home/` and `source_rev`.

## Consequences

The top level drops from 35 directories to about nine, and content directories hold only authored pages. The cost is a one-time move of about 350 files and updates to the generator, the `--i18n-pages` check, TRANSLATING.md and CONTRIBUTING.md.

A translated page's URL now lives in its front matter, not in its path, so the generator owns that field. A hand-written permalink that disagrees with it is reported.
