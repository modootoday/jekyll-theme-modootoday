---
id: adr:modootoday/20261103053014
title: URL aliases are md.txt stubs that follow the modootoday.aliases declaration
status: active
created: 2026-11-03T05:30:14Z
updated: 2026-11-03T05:30:44Z
rel:
  governs: [lib/modootoday/check/build]
---

# URL aliases are md.txt stubs that follow the modootoday.aliases declaration

## Context

Agents ask for `/<page>.md` and `/<page>.html` as well as the twin at `/<page>/index.md`. The feature design names the HTML alias stub `<name>.html.md` in one place and `<name>.html.redirect.md` in another. Any name ending in `.md` is a Markdown page to the checker, to `script/docs-index` and to `llms.txt`, so it would need a twin and pass every page rule.

## Decision

- Both alias stubs end in `.md.txt`, like twin stubs: `<name>.flat.md.txt` (`layout: twin`, `twin_of`, `permalink: /<name>.md`) and `<name>.html.md.txt` (`layout: redirect`, `redirect_to: /<name>/`, `permalink: /<name>.html`, `sitemap: false`). No page glob, `llms.txt` list, search index or file-count rule sees them as pages. A twin stub is `<name>.md.txt` without either inner suffix.
- `modootoday.aliases: {md, html}` is the declaration both tools read: `--aliases` writes and checks only the kinds set to `true`, and is an error when none is. A stub of a kind that is turned off is pruned.
- Aliases exist for pages with a directory URL other than `/` (`README.md` excepted). A page with `twin: false` has no flat alias. A page whose permalink is a file, such as `/404.html`, has none.
- The HTML alias is a redirect, not a second copy, so one URL is indexed. The `redirect` layout already gives a meta refresh, a canonical link and `noindex` without a plugin or script.
- The flat alias is refused with `twins: source` (config check, stub writer exit 2): a page without front matter is already copied raw to `/<name>.md`.
- `modootoday-check --aliases` (`build/aliases.rb`): a missing alias, a flat alias that is not byte-identical to the built twin, and an HTML alias whose refresh target or canonical is not the page are errors, as are two pages with one alias and an alias at the path of another source file. Without `baseurl` in `_config.yml` the expected prefix is taken from the refresh target, because the Pages builder sets `baseurl` and `url` for project sites (seen with the classic builder image).
- The Jekyll 4 generator plugin does not add aliases; sites that want them use the stubs.

## Consequences

Sites without `modootoday.aliases` build byte-identical output. The CI job that runs the real Pages builder turns both aliases on in a copy of the example, writes the stubs with `modootoday-stubs` and runs the checker with `--twins --aliases`.
