---
id: adr:modootoday/20261110033804
title: "The starters set the theme's mark as their site icon, and the theme default stays unset"
status: active
created: 2026-11-10T03:38:04Z
updated: 2026-11-10T03:43:16Z
rel:
  governs: [example/starters.yml]
---

# The starters set the theme's mark as their site icon, and the theme default stays unset

## Context

A page that links no icon makes the browser request `/favicon.ico` at the host root. A starter demo is served under a `baseurl`, so that path is outside its site. The request returned 404 and Chrome logged a console error. Lighthouse counts that error under best practices (errors-in-console), so the docs, blog and landing demos scored 96 against a budget of 100. None of the starters set `modootoday.favicon`.

Two fixes were weighed:

- **The theme links its mark whenever a site sets no icon.** This fixes every site at once, but it changes the head of every existing site without the key. A site that keeps its icon at the root `/favicon.ico`, or adds its own icon link in `head-custom.html`, would show the theme's mark or carry two icon links.
- **The starters set `favicon: brand`.** Only new sites made from a starter change, and their owners see the setting in `_config.yml`.

## Decision

- `modootoday.favicon` keeps its current behaviour: unset prints no icon link, `brand` links the theme's mark, and a path links that icon.
- Each starter's `_config.yml` sets `modootoday.favicon: brand`, with a comment saying a path to your own icon replaces it. Both stacks render from that file, so the demo build and a copy made from the template carry the icon link.
- `test/starters/` checks that every starter in `example/starters.yml` sets it.

## Consequences

- The starter demos request no `/favicon.ico`, so errors-in-console passes once the published starters carry the setting.
- A site built without a starter that is served under a `baseurl` and sets no icon still logs the 404. It sets `favicon:` (`brand` or a path) to fix it.
