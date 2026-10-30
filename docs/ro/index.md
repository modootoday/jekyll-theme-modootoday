---
toc: false
hero: {visual: showcase}
title: Acasă
description: Documentație în Markdown simplu, ușor de citit pe GitHub, pe GitHub Pages și de agenții AI.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Documentație care rămâne Markdown simplu

jekyll-theme-modootoday transformă GitHub Flavored Markdown standard într-un site de documentație curat. Același fișier se citește bine pe github.com, pe GitHub Pages și ca versiune Markdown pentru agenții AI.

[Începe](../guides/install/) [Vezi componentele](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## De ce modootoday

- **Doar Markdown standard** — Alerte, tabele, liste și blocuri de cod. Fără HTML, Liquid sau extensii kramdown în paginile tale.
- **Funcționează pe GitHub Pages** — O temă doar cu Liquid pentru build-ul clasic `github-pages`, iar pentru restul, Jekyll 4.
- **Ușor de citit de agenți** — Fiecare pagină are o versiune Markdown identică byte cu byte, plus `llms.txt` și `llms-full.txt`.

## Pornire rapidă

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.0.0
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.0"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## Drumul tău prin documentație

1. [Instalează](../guides/install/) tema pe GitHub Pages sau Jekyll 4.
2. [Scrie prima pagină](../guides/first-page/) în Markdown simplu.
3. Alege dintre [componente](../components/) și din [pagina cu toate componentele](../components/kitchen-sink/).
4. Ajustează [configurația](../guides/configuration/) și [personalizează](../guides/customize/) aspectul cu tokenuri și `_sass`.
5. Fă site-ul [ușor de citit de agenți](../guides/agents/) cu versiuni Markdown și `llms.txt`.

> [!NOTE]
> Această pagină este o traducere a [originalului în engleză](../); în caz de diferențe, prevalează varianta în engleză. Ghidurile din linkuri sunt în engleză.

## Începe acum

[Instalează tema](../guides/install/) [Vezi toate componentele](../components/kitchen-sink/)
