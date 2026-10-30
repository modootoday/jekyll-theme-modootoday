---
toc: false
hero: {visual: showcase}
title: Home
description: Documentazione in Markdown semplice, leggibile su GitHub, su GitHub Pages e dagli agenti IA.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Documentazione che resta Markdown semplice

jekyll-theme-modootoday trasforma il GitHub Flavored Markdown standard in un sito di documentazione pulito. Lo stesso file si legge bene su github.com, su GitHub Pages e come versione Markdown per gli agenti IA.

[Inizia](../guides/install/) [Sfoglia i componenti](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Perché il tema modoo.today

- **Solo Markdown standard** — Avvisi, tabelle, elenchi e blocchi di codice. Niente HTML, Liquid o estensioni kramdown nelle tue pagine.
- **Funziona su GitHub Pages** — Un tema solo Liquid per la build classica `github-pages`, e Jekyll 4 per tutto il resto.
- **Leggibile dagli agenti** — Ogni pagina ha una versione Markdown identica byte per byte, oltre a `llms.txt` e `llms-full.txt`.

## Avvio rapido

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.1.1
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

## Il tuo percorso nella documentazione

1. [Installa](../guides/install/) il tema su GitHub Pages o Jekyll 4.
2. [Scrivi la tua prima pagina](../guides/first-page/) in Markdown semplice.
3. Scegli tra i [componenti](../components/) e la [pagina con tutti i componenti](../components/kitchen-sink/).
4. Regola la [configurazione](../guides/configuration/) e [personalizza](../guides/customize/) l’aspetto con i token e `_sass`.
5. Rendi il sito [leggibile dagli agenti](../guides/agents/) con le versioni Markdown e `llms.txt`.

> [!NOTE]
> Questa pagina è una traduzione dell’[originale inglese](../); in caso di differenze vale la versione inglese. Le guide collegate sono in inglese.

## Inizia ora

[Installa il tema](../guides/install/) [Vedi tutti i componenti](../components/kitchen-sink/)
