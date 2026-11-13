---
nav_order: 85
title: Translate your site
description: The steps to publish your own site in more than one language, from the language list to the check that finds missing and outdated translations.
---
# Translate your site

This page is for site authors. To translate the theme's own docs or interface strings, read [Translation rules](../translation/) instead. Each step below links the full rules in [Configuration](../configuration/#languages).

## Steps

1. List the languages in `_config.yml`. `lang:` is the default language; `languages` lists every language the site has, such as `[en, ko]`. The theme's own labels already come in 23 languages, so there is nothing to copy.
2. Translate each page as Markdown, beside its source (`guides/start.ko.md` next to `guides/start.md`, with `lang: ko` and `permalink: /ko/guides/start/`) or in a language folder (`ko/guides/start.md`, with a `defaults` scope that sets `lang: ko` for `path: ko`). Pages whose paths differ share a `ref:`.
3. Give every language a home page at `/<lang>/`, such as `index.ko.md` with `lang: ko` and `permalink: /ko/`. The language menu sends readers there from pages that have no translation.
4. Turn on the language menu with `language_switcher: header` or `footer`.
5. Put the labels that are your site's, such as `tabs.label`, in `_data/i18n/<lang>.yml` for each language, with any theme label you want to word differently.
6. Set `full_languages` to the languages that translate every page, and run the check below after each build. It lists pages with no translation, and translations without `source_rev` or whose source changed since. It prints the current `source_rev` value; put it in the translation's front matter once the translation matches its source again.

```yaml
lang: en
modootoday:
  languages: [en, ko]
  full_languages: [ko]
  language_switcher: header
```

```sh
bundle exec modootoday-check . _site --i18n-pages
```

The findings are warnings; add `--strict` to make them fail, for example in CI. Add `--links` to find a language menu link to a missing home page.
