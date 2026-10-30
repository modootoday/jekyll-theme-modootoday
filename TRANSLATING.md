# Translating

English is canonical; every other language is localized from it. The rules, register table and glossary highlights are in [docs/guides/translation.md](docs/guides/translation.md) (also in [한국어](docs/ko/guides/translation.md) and [日本語](docs/ja/guides/translation.md)). The full glossary, with the wordings to avoid, is [`i18n/glossary.yml`](i18n/glossary.yml). The decisions are in the ADRs under [`.spec/adr/`](.spec/adr/). This file is the contributor checklist.

## Checklist

1. Read the English change and rewrite it the way a native technical writer would; do not translate word for word.
2. Use the glossary term for every concept; add a new term to `i18n/glossary.yml` in the same pull request.
3. Korean docs: 합니다체. Korean interface sentences: 해요체. Japanese: です・ます. Labels and headings: noun phrases.
4. Leave code, paths, keys, Liquid, URLs and product names untouched.
5. Run `script/i18n-build --check`. It fails on stale catalogs, key or placeholder drift, glossary terms to avoid, calques, the wrong register and untranslated English.
6. Update translations in the same pull request as the English change, or list the pages left behind.

## Interface strings

The theme's labels live in `i18n/<code>.yml`; `i18n/en.yml` is the registry of every key. A translation has the same keys and placeholders (`%{n}`) and only changes the values. Labels are short: 이 페이지 편집 / このページを編集, not full sentences. Use `.yml`, never `.yaml`.

After editing `i18n/*.yml`, run `rake i18n` (or `script/i18n-build`). It regenerates `_includes/modootoday/i18n/<code>.html`, the loader `_includes/modootoday/i18n.html` and `_includes/modootoday/t.html`; never edit those by hand. CI runs `script/i18n-build --check` and fails when they are stale or a catalog has missing keys or mismatched placeholders. Layouts and includes read labels only through these generated files, with no inline English.

## Adding a language

1. Add the language to `i18n/languages.yml` (code, endonym, English name, `dir`).
2. Copy `i18n/en.yml` to `i18n/<code>.yml`, set `language:` and `direction:` and localize the values.
3. Run `rake i18n` and `rake test`; the build test renders a page in every language.
4. Add a column to `i18n/glossary.yml` once a native reviewer approves the terms.
5. For the docs site, also add `docs/_data/i18n/<code>.yml` with the docs-only keys (`title`, `description`, `tabs.label`) and translate at least `<code>/index.md` before listing the code in `modootoday.languages`. Check that the font covers the script.

## Languages

The docs target the 23 languages in `docs/_data/languages.yml`. Interface labels come from the theme catalogs; `docs/_data/i18n/<code>.yml` holds only docs-specific strings and deliberate overrides; a language is listed in `modootoday.languages` only when its home page is localized. Per-language tone notes are in the ADR. Never leave a page half-translated: until a page is fully localized, the language uses the labeled English fallback.
