---
toc: false
hero: {visual: showcase}
title: Strona główna
description: Dokumentacja w zwykłym Markdownie, czytelna na GitHubie, w GitHub Pages i dla agentów AI.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Dokumentacja, która pozostaje zwykłym Markdownem

jekyll-theme-modootoday zamienia standardowy GitHub Flavored Markdown w przejrzystą witrynę z dokumentacją. Ten sam plik dobrze się czyta na github.com, w GitHub Pages i jako wersja Markdown dla agentów AI.

[Zacznij](../guides/install/) [Przeglądaj komponenty](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Dlaczego modootoday

- **Tylko standardowy Markdown** — Alerty, tabele, listy i bloki kodu. Bez HTML, Liquid i rozszerzeń kramdown na stronach.
- **Działa w GitHub Pages** — Motyw oparty wyłącznie na Liquid dla klasycznej kompilacji `github-pages`, a w pozostałych przypadkach Jekyll 4.
- **Czytelna dla agentów** — Każda strona ma identyczną co do bajtu wersję Markdown oraz pliki `llms.txt` i `llms-full.txt`.

## Szybki start

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.1.0
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.1"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## Jak czytać dokumentację

1. [Zainstaluj](../guides/install/) motyw w GitHub Pages lub Jekyll 4.
2. [Napisz pierwszą stronę](../guides/first-page/) w zwykłym Markdownie.
3. Wybierz spośród [komponentów](../components/) i na [stronie ze wszystkimi komponentami](../components/kitchen-sink/).
4. Dostosuj [konfigurację](../guides/configuration/) i [zmień wygląd](../guides/customize/) za pomocą tokenów i `_sass`.
5. Spraw, by witryna była [czytelna dla agentów](../guides/agents/) dzięki wersjom Markdown i `llms.txt`.

> [!NOTE]
> Ta strona jest tłumaczeniem [angielskiego oryginału](../); w razie rozbieżności obowiązuje wersja angielska. Podlinkowane przewodniki są po angielsku.

## Zacznij teraz

[Zainstaluj motyw](../guides/install/) [Zobacz wszystkie komponenty](../components/kitchen-sink/)
