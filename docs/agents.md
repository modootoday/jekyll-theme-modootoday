---
title: For agents
description: Markdown twins, llms.txt and llms-full.txt for AI agents.
sections:
  - twins
  - llms
  - {c: cta, name: next}
---
# Agent-readable Markdown

Every page is published twice: as HTML for people and as its original Markdown for agents.

## Markdown twins

A page `guide.md` is also served at `/guide/index.md`, byte-identical to its body. On Jekyll 4 the theme plugin creates twins automatically:

```yaml
plugins: [jekyll-theme-modootoday]
```

The classic GitHub Pages build cannot run plugins, so add a stub next to each page instead:

```yaml
# guide.md.txt
---
layout: twin
twin_of: guide.md
permalink: /guide/index.md
---
```

`twin_of` is a path relative to the stub file (it is read with `include_relative`), so keep the stub in the same folder as its page or use `../` paths. It cannot point outside the site source or into `_` folders.

Each HTML page links its twin with `rel="alternate" type="text/markdown"`.

## llms.txt

`/llms.txt` lists every page of a language, following [llmstxt.org](https://llmstxt.org). `/llms-full.txt` concatenates every page body. Both come from one-line stubs:

```yaml
---
layout: llms
---
```

Try them on this site: [llms.txt](../llms.txt) and [llms-full.txt](../llms-full.txt).

## Next

[Changelog](../changelog/) [Home](../)
