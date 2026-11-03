---
id: adr:modootoday/20261103071902
title: Docs keep authored pages and translations side by side; tool output lives under generated/
status: active
created: 2026-11-03T07:19:02Z
updated: 2026-11-03T12:27:54Z
rel:
  governs: [docs/_config.yml, script/docs/outputs.rb, lib/modootoday/stubs/twins.rb, script/docs/translations.rb, script/docs/tree.rb]
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

Step 1 is done:

- `script/docs-index` owns `docs/generated/`. It writes the twin stubs through `Stubs::Twins` with `dir: "generated"`, and an `llms.txt` and `llms-full.txt` stub for each language with a home page. Under `--check`, a file there that no output wants is out of date.
- Each stub sets `path:` to the path it would have beside its page (`guides/install.md.txt`, `ko/llms.txt`), plus its `permalink:`. The twin layout resolves `include_relative` from that path, and the llms layouts take their directory from it. This works on the classic builder and on Jekyll 4; without `path:`, the build fails.
- A `defaults` scope matches the real path, not `path:`. So a stub copies the `lang:` that `_config.yml` defaults give its old place (`Stubs::Source#default`). The llms layouts filter pages by it, and a reference page's twin labels its packages table in it.
- The classic builder's relative-links plugin matches a link against each page's real path, not `path:`. A Markdown link to a stub's old place therefore no longer turns into its URL. The ko and ja Agents guides link `../../llms.txt`. The classic build used to turn that into the root `/llms.txt`. It now keeps the link relative, so it reaches `/<lang>/llms.txt`, the same target the Jekyll 4 build always had.
- The directory is `generated`, not `_generated`, because Jekyll does not read underscore directories. It is not in `exclude`.
- User sites keep their stubs next to their pages: `modootoday-stubs` does not set `dir:`. `modootoday-check --twins` accepts a stub in either place.

Step 2 is done:

- 194 files moved. Each of ko and ja moved 86 pages and its feed beside the English source (`guides/install.ko.md`, `index.ko.md`, `feed.ko.xml`). The 20 languages with only a home page moved it to `home/index.<code>.md`. The 22 per-language `defaults` scopes are gone, and `modootoday.full_languages` is `[ko, ja]`.
- `script/docs-index` writes `lang:` and `permalink:` into every translation on each run. `source_rev:` is written only by `script/docs-index --stamp PATH...`, and every translation was stamped once at its current source. The home-only languages are stamped too: their home pages changed together with the English one in every release so far.
- A page's language and source come from adr:modootoday/20261103121248 (`Modootoday::I18n::PageLang`), never from a second copy of the rule.
- Twin stubs follow their pages to `generated/guides/install.ko.md.txt` and `generated/home/index.vi.md.txt`. The llms stubs keep their files and URLs (`generated/ko/llms.txt` at `/ko/llms.txt`), but every one now sets `path: llms.txt`, because a language's pages are spread over the whole tree. `lang:` picks the pages, and the theme lists the translations only in the default language's root `llms.txt`.
- The layout test and the docs QA count a translation as its English page. So a directory holds as many files as it has English pages, and `home/` needs no flat-directory exception.
- The built site keeps every URL. Two intended differences remain:
  - Each translated page's edit link points at its new source path.
  - `search.json` lists pages in URL order. A separate commit before the move sorts it, so the order no longer depends on file names.
- One unintended difference comes from an older theme bug. The `resume` layout and the profile JSON-LD read `page.name`, which Jekyll always sets to the file name, so the person's `name:` from front matter is never used. The ko and ja Resume and Links demos therefore showed `resume.md` and `links.md` and now show `resume.ko.md`, `links.ja.md` and so on. Fixing the layouts changes every language's output, so it is left to its own change.
- The sitemap is compared as a set of `<url>` entries.
- The classic builder's relative-links plugin resolves a link that names an existing file from the file's real path. Before the move a translation's real path mirrored its URL, so both builders agreed. After it:
  - Links that reached a file through the old folder no longer match a file. The classic build now keeps them relative, as Jekyll 4 always did, and they reach the same target: the images on the ko and ja Components pages and the other-language feed links on the Blog and news page.
  - Three links would have reached the wrong file or none, so they now name their target by URL: each language's own feed link on the Blog and news page (`../../../ko/feed.xml`, which `../../feed.xml` would have turned into the English feed) and the image on the Japanese kitchen sink (`../../../assets/...`, which was already broken on Jekyll 4).
  - TRANSLATING.md asks for links written as URLs.
- The relative links inside the translations are written as URLs (`../../guides/install/`), not as `.md` paths, so the classic relative-links plugin leaves them alone, and they resolve the same from the unchanged URLs.
