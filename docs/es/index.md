---
toc: false
hero: {visual: showcase}
title: Inicio
description: Documentación en Markdown simple que se lee bien en GitHub, en GitHub Pages y para agentes de IA.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Documentación que sigue siendo Markdown simple

jekyll-theme-modootoday convierte GitHub Flavored Markdown estándar en un sitio de documentación limpio. El mismo archivo se lee bien en github.com, en GitHub Pages y como versión Markdown para agentes de IA.

[Empieza](../guides/install/) [Explora los componentes](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Por qué modootoday

- **Solo Markdown estándar** — Alertas, tablas, listas y bloques de código. Sin HTML, sin Liquid y sin extensiones de kramdown en tus páginas.
- **Funciona en GitHub Pages** — Un tema solo con Liquid para la compilación clásica `github-pages`, y Jekyll 4 para todo lo demás.
- **Legible para agentes** — Cada página tiene una versión Markdown idéntica byte a byte, además de `llms.txt` y `llms-full.txt`.

## Inicio rápido

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

## Tu recorrido por la documentación

1. [Instala](../guides/install/) el tema en GitHub Pages o Jekyll 4.
2. [Escribe tu primera página](../guides/first-page/) con Markdown simple.
3. Elige entre los [componentes](../components/) y la [página con todos los componentes](../components/kitchen-sink/).
4. Ajústalo en la [configuración](../guides/configuration/) y [personaliza](../guides/customize/) el aspecto con tokens y `_sass`.
5. Haz que sea [legible para agentes](../guides/agents/) con versiones Markdown y `llms.txt`.

> [!NOTE]
> Esta página es una traducción del [original en inglés](../); si hay diferencias, prevalece el inglés. Las guías enlazadas están en inglés.

## Empieza ahora

[Instala el tema](../guides/install/) [Ver todos los componentes](../components/kitchen-sink/)
