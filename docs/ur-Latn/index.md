---
toc: false
hero: {visual: showcase}
title: Home
description: Docs jo saada Markdown hi rehti hain, aur GitHub, GitHub Pages aur AI agents ke liye aasaani se parhi jati hain.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Docs jo saada Markdown hi rehti hain

jekyll-theme-modootoday standard GitHub Flavored Markdown ko ek saaf suthri documentation site mein badal deta hai. Wohi file github.com par, GitHub Pages par aur AI agents ke liye Markdown version ke taur par achhi tarah parhi jati hai.

[Shuru karein](../guides/install/) [Components dekhein](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## modoo.today theme kyun

- **Sirf standard Markdown** — Alerts, tables, lists aur code blocks. Aap ke pages mein HTML, Liquid ya kramdown extras ki zaroorat nahin.
- **GitHub Pages par chalta hai** — Classic `github-pages` build ke liye sirf Liquid wala theme, aur baaqi sab ke liye Jekyll 4.
- **Agents ke liye readable** — Har page ka byte-for-byte same Markdown version hai, saath mein `llms.txt` aur `llms-full.txt` bhi.

## Quick start

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.2.0
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.2"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## Docs mein aap ka raasta

1. Theme ko GitHub Pages ya Jekyll 4 par [install karein](../guides/install/).
2. Saada Markdown mein [apna pehla page likhein](../guides/first-page/).
3. [Components](../components/) aur [tamam components wale page](../components/kitchen-sink/) se chunein.
4. [Configuration](../guides/configuration/) mein settings badlein aur tokens aur `_sass` se look [customize karein](../guides/customize/).
5. Markdown versions aur `llms.txt` se site ko [agents ke liye readable](../guides/agents/) banayein.

> [!NOTE]
> Yeh page [English original](../) ka tarjuma hai; farq ho to English version maana jaye ga. Link kiye gaye guides English mein hain.

## Abhi shuru karein

[Theme install karein](../guides/install/) [Tamam components dekhein](../components/kitchen-sink/)
