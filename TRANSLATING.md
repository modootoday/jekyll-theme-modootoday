# Translating

English is canonical; every other language is localized from it. The rules, register table and glossary highlights are in [docs/guides/translation.md](docs/guides/translation.md) (also in [한국어](docs/guides/translation.ko.md) and [日本語](docs/guides/translation.ja.md)). The full glossary, with the wordings to avoid, is [`i18n/glossary.yml`](i18n/glossary.yml). The decisions are in the ADRs under [`.spec/adr/`](.spec/adr/). This file is the contributor checklist.

## Checklist

1. Read the English change and rewrite it the way a native technical writer would; do not translate word for word.
2. Use the glossary term for every concept; add a new term to `i18n/glossary.yml` in the same pull request.
3. Korean docs: 합니다체. Korean interface sentences: 해요체. Japanese: です・ます. Labels and headings: noun phrases.
4. Leave code, paths, keys, Liquid, URLs and product names untouched.
5. Run `script/i18n-build --check`. It fails on stale catalogs, key or placeholder drift, glossary terms to avoid, calques, the wrong register and untranslated English.
6. Update translations in the same pull request as the English change, or list the pages left behind.
7. Once a translation matches its English page again, stamp it: `ruby script/docs-index --stamp docs/guides/install.ko.md`. `modootoday-check docs docs/_site --i18n-pages` lists the translations whose English page changed since their stamp.

## Where translations live

A docs translation sits beside its English page: `docs/guides/install.ko.md` and `docs/guides/install.ja.md` next to `docs/guides/install.md`. Edit both in the same pull request. A language that translates only the home page keeps it in `docs/home/` (`docs/home/index.vi.md`).

Write links in a translation as URLs relative to the page's URL (`../../guides/install/`, `../../../ko/feed.xml`), never as file paths. The classic GitHub Pages build resolves a link that names an existing file from the file's real place, which no longer mirrors its URL, so `../../feed.xml` in `layouts/blog-news/index.ko.md` would reach the English feed.

`ruby script/docs-index` owns three front matter keys in a translation; do not write them by hand:

- `lang:` comes from the file name.
- `permalink:` is the English page's URL under `/<code>` (`/ko/guides/install/`), because Jekyll cannot derive that URL from `install.ko.md`.
- `source_rev:` records which revision of the English page the translation follows (`sha256:` and 12 hex digits of its `title`, `description`, `nav_title` and body). Only `--stamp` writes it, and `--check` never changes it. A translation without one, or whose English page changed since, is a warning in `--i18n-pages`.

## Interface strings

The theme's labels live in `i18n/<code>.yml`; `i18n/en.yml` is the registry of every key. A translation has the same keys and placeholders (`%{n}`) and only changes the values. Labels are short: 이 페이지 편집 / このページを編集, not full sentences. Use `.yml`, never `.yaml`.

After editing `i18n/*.yml`, run `rake i18n` (or `script/i18n-build`). It regenerates `_includes/modootoday/i18n/<code>.html`, the loader `_includes/modootoday/i18n.html`, `_includes/modootoday/t.html` and the docs copy of the language list, `docs/_data/languages.yml`; never edit those by hand. CI runs `script/i18n-build --check` and fails when they are stale or a catalog has missing keys or mismatched placeholders. Layouts and includes read labels only through these generated files, with no inline English.

## Adding a language

1. Add the language to `i18n/languages.yml` (code, endonym, English name, `dir`).
2. Copy `i18n/en.yml` to `i18n/<code>.yml`, set `language:` and `direction:` and localize the values.
3. Run `rake i18n` and `rake test`; the build test renders a page in every language.
4. Add a column to `i18n/glossary.yml` once a native reviewer approves the terms.
5. For the docs site, also add `docs/_data/i18n/<code>.yml` with the docs-only keys (`title`, `description`, `tabs.label`) and localize at least the home page as `docs/home/index.<code>.md`. Then add the code to `modootoday.languages` in `docs/_config.yml` and run `ruby script/docs-index`, which writes the page's `lang:` and `permalink:` and the language's `llms.txt` and `llms-full.txt` stubs under `docs/generated/<code>/`. Stamp the page with `ruby script/docs-index --stamp docs/home/index.<code>.md`. Check that the font covers the script.

## Languages

The docs target the 23 languages in `i18n/languages.yml` (copied to `docs/_data/languages.yml` by `script/i18n-build`), and all 23 are listed in `modootoday.languages`. Interface labels come from the theme catalogs; `docs/_data/i18n/<code>.yml` holds only docs-specific strings and deliberate overrides; a language is listed in `modootoday.languages` only when its home page is localized. Per-language tone notes are in the ADR. Never leave a page half-translated: until a page is fully localized, the language uses the labeled English fallback: a localized home links to the English guides and says so in a closing `[!NOTE]`, and the sidebar falls back to the English menu (`script/docs-index` writes `_data/nav/main-<code>.yml` only for a language whose menu differs).
