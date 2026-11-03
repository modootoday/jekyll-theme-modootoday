---
id: adr:modootoday/20261103121248
title: One owner decides a page's language and its source revision
status: active
created: 2026-11-03T12:12:48Z
updated: 2026-11-03T12:13:09Z
rel:
  governs: [lib/modootoday/i18n]
---

# One owner decides a page's language and its source revision

## Context

adr:modootoday/20261103071902 moves the docs translations beside their sources (`guides/install.ko.md`) and gives each one a `source_rev`. Before this change, four places decided a page's language from its path, each in its own way:

- the checker context (`lang_of`, a folder with a catalog),
- `--i18n-pages` (front matter, else a folder listed in `languages`),
- the docs generator (the first folder),
- the plugin and `--twins` (a folder that exists on disk).

None of them knew a `.ko.md` suffix. Adding the suffix to each would have made five copies of one rule.

## Decision

- `lib/modootoday/i18n/` in the gem owns the rule. Callers load it through `lib/modootoday/i18n.rb`.
  - `PageLang` answers which language a file is in and which default-language file it translates. A front matter `lang:` wins, then a `.<lang>` suffix before the extension, then a `<lang>/` folder. A file under `home/` translates the file without that prefix. `PageLang` also gives a translation's URL: its source's URL under `/<lang>`.
  - `SourceRev` is the one hash: `sha256:` and the first 12 hex digits of the source's SHA-256. The input is the source with LF line endings, the `title`, `description` and `nav_title` front matter values, and the body with the generated page lists (the `spec:docs-index` blocks) removed. Other front matter keys are left out, so changing `nav_order` or a layout setting does not mark the translations stale.
- The checker (`Context#page_lang`, `--twins`, `--i18n-pages`), `script/docs-index`, the docs QA and the layout test all use `PageLang`. `SourceRev` is used by the checker, which compares it, and by `script/docs-index --stamp`, which writes it.
- Both layouts keep working. User sites with translations in `<lang>/` folders and `defaults` scopes see the same URLs and twins as before.
- `--i18n-pages` reports `source_rev` in both layouts:
  - A translation without `source_rev`, or with a stale one, is a warning that names the current value. `--strict` fails on it.
  - A sibling translation's `permalink` must equal its source's URL under `/<lang>`, because the file name gives Jekyll no usable URL. A mismatch is an error.
  - The missing-translation scan leaves out pages that are not translated page by page: posts (each language writes its own dated posts), record pages and lists of records (made from data), and pages at a file URL such as `/404.html` (the host serves that one file). Without this, setting `full_languages` on the docs site reported 22 pages that have no translation by design.
- `--twins` and the plugin give `llms.txt` and `llms-full.txt` to each language that has pages, not to each language folder that exists on disk. A language whose pages sit beside their sources gets llms stubs that list the whole tree in that language, so only the default language's root `llms.txt` carries the Translations list.

## Consequences

A site with translations in `<lang>/` folders now gets one `no source_rev` warning per translation from `--i18n-pages` until it stamps them. That is the point of the option, and the warning prints the value to set.

The suffix rule reads any language code listed in `modootoday.languages` or with a catalog. A default-language file whose name happens to end in `.<code>.md`, such as `notes.it.md` on a site that lists `it`, would read as a translation. Such a file can set `lang:` in its front matter, which wins.
