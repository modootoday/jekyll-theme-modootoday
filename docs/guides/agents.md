---
nav_order: 60
title: AI agents
description: Publish each page's Markdown twin, URL aliases, llms.txt and llms-full.txt so AI agents read your site as written.
sections:
  - twins
  - aliases
  - llms
---
# AI agents

Every page is published twice: as HTML for people and as its original Markdown for agents.

## Markdown twins

A page `guide.md` is also served at `/guide/index.md`, byte-identical to its body. Pick one of three ways to publish twins; switching between them does not change page bodies:

- **Stub files** (default, classic GitHub Pages): one small `<page>.md.txt` per page, shown below.
- **Plugin** (Jekyll 4 or GitHub Actions): `plugins: [jekyll-theme-modootoday]` creates twins and `llms.txt` without stubs.
- **Source mode** (classic GitHub Pages, no stubs): `modootoday.twins: source` with pages that have no front matter. Classic GitHub Pages serves the raw copy as `text/markdown; charset=utf-8`, identical to the source; section 5a of the [Markdown rules](../../reference/rules/) lists the limits.

On Jekyll 4 the theme plugin creates twins automatically:

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

```yaml
# guides/install.md.txt, next to guides/install.md
twin_of: install.md          # correct: relative to the stub
twin_of: guides/install.md   # wrong: a path from the site root fails with "Could not locate the included file"
```

Each HTML page links its twin with `rel="alternate" type="text/markdown"`.

`modootoday-stubs` writes the stubs for you. Without `--write` it only lists what it would create, update or delete; in CI, `--check` fails when a stub is missing, out of date or left over after its page was removed.

```sh
modootoday-stubs . --twins           # list missing, stale and orphan stubs
modootoday-stubs . --twins --write   # write them
modootoday-stubs . --twins --check   # CI: exit 1 when anything would change
```

## URL aliases

Some agents ask for `/guide.md` or `/guide.html` instead of `/guide/`. Declare the aliases you want in `_config.yml`:

```yaml
modootoday:
  aliases: {md: true, html: true}
```

Then `modootoday-stubs . --aliases --write` adds up to two stubs for each page with a directory URL (the home page has none):

- `guide.flat.md.txt` serves the twin again at `/guide.md`, with the same bytes.
- `guide.html.md.txt` uses the `redirect` layout: `/guide.html` sends readers to `/guide/` with a meta refresh, names `/guide/` as canonical and is `noindex`, so search engines keep one URL. It needs no plugin and no script, so it works on classic GitHub Pages and under a strict CSP.

`modootoday-check . _site --aliases` checks that every alias is in the build and points at its page. Two pages with the same alias, or an alias at the path of another file, are errors. The flat alias cannot be combined with `twins: source`, where a page without front matter is already served at `/guide.md`.

## llms.txt

`/llms.txt` lists every page of a language, following [llmstxt.org](https://llmstxt.org). `/llms-full.txt` concatenates every page body. The plugin adds both; on classic GitHub Pages they come from two files at the site root that hold only front matter, `llms.txt` and `llms-full.txt`:

```yaml
# llms.txt (llms-full.txt is the same with layout: llms-full)
---
layout: llms
---
```

Each other language with pages needs the same two files in its folder with its `lang:`, such as `ko/llms.txt` with `layout: llms` and `lang: ko`. `modootoday-check --twins` names any that are missing.

Try them on this site: [llms.txt](../../llms.txt) and [llms-full.txt](../../llms-full.txt). [Install > Verify the build](../install/#verify-the-build) runs the checks on your own site.
