---
toc: false
hero: {visual: showcase}
title: Início
description: Documentação em Markdown simples que fica bem no GitHub, no GitHub Pages e para agentes de IA.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Documentação que continua sendo Markdown simples

O jekyll-theme-modootoday transforma GitHub Flavored Markdown padrão em um site de documentação limpo. O mesmo arquivo fica legível no github.com, no GitHub Pages e como versão Markdown para agentes de IA.

[Comece](../guides/install/) [Veja os componentes](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Por que o tema modoo.today

- **Só Markdown padrão** — Alertas, tabelas, listas e blocos de código. Nada de HTML, Liquid ou extensões do kramdown nas suas páginas.
- **Funciona no GitHub Pages** — Um tema só com Liquid para o build clássico `github-pages`, e Jekyll 4 para todo o resto.
- **Legível para agentes** — Toda página tem uma versão Markdown idêntica byte a byte, além de `llms.txt` e `llms-full.txt`.

## Início rápido

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

## Seu caminho pela documentação

1. [Instale](../guides/install/) o tema no GitHub Pages ou no Jekyll 4.
2. [Escreva sua primeira página](../guides/first-page/) em Markdown simples.
3. Escolha entre os [componentes](../components/) e a [página com todos os componentes](../components/kitchen-sink/).
4. Ajuste na [configuração](../guides/configuration/) e [personalize](../guides/customize/) o visual com tokens e `_sass`.
5. Deixe o site [legível para agentes](../guides/agents/) com versões Markdown e `llms.txt`.

> [!NOTE]
> Esta página é uma tradução do [original em inglês](../); se houver diferenças, vale o inglês. Os guias com link estão em inglês.

## Comece agora

[Instale o tema](../guides/install/) [Veja todos os componentes](../components/kitchen-sink/)
