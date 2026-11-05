---
id: adr:modootoday/20261105092848
title: Stale diagrams are found by digest and rendered by a repository script with a pinned Mermaid in any Chromium
status: active
created: 2026-11-05T09:28:48Z
updated: 2026-11-05T09:29:11Z
rel:
  governs: [script/figures, .github/workflows/figures.yml, lib/modootoday/check/page/figures/freshness.rb]
  depends_on: [adr:modootoday/20261105075445]
---

# Stale diagrams are found by digest and rendered by a repository script with a pinned Mermaid in any Chromium

## Context

adr:modootoday/20261105075445 ties each committed diagram SVG to its fence with `data-mt-src`, but nothing compared the two, so an edited fence with an old SVG went unnoticed. The 1.6.0 plan asked for a stale-figure check, a list for pre-commit hooks and a render script built on `@mermaid-js/mermaid-cli`. Rendering Mermaid needs a browser, and a contributor may have none on the machine that edits the docs.

## Decision

- **Stale means a recorded digest that differs.** For every entry of `diagrams:` with a fence, `modootoday-check` compares the `data-mt-src` of each committed SVG with `Modootoday::Figures.digest` of the fence and reports "stale diagram" as an error. An SVG without the attribute is hand-made and not compared, so the check never forces a renderer on anyone. A missing file stays the error of `page/figures/diagrams.rb`.
- **`modootoday-check SRC --diagrams` is a list mode, not a check.** It reads only the sources (SITE is optional), prints a JSON array `[{page, name, line, fence, digest, files, reason}]` of the diagrams whose SVG is missing or stale and exits 1 when the array is not empty. `files` maps the Mermaid theme to the path to write (`default`, and `dark` unless `dark: false`), so a renderer needs no knowledge of the settings and the fence parser stays in Ruby alone.
- **The renderer is `script/figures/diagrams.mjs`, outside the gem.** It reads that list, loads Mermaid in a blank page from a pinned jsDelivr URL with its `sha384` integrity (the hash of `dist/mermaid.min.js` in the npm tarball), renders each fence with the `default` and `dark` themes, fixes the root id from the digest, sizes the root from its `viewBox` and writes `data-mt-src`. It refuses a list entry whose digest `script/figures/digest.mjs` computes differently; that Node copy of the rule is held to the Ruby owner by the shared cases in `test/fixtures/figures/digests.json`.
- **Any Chromium, three ways.** The script drives a Playwright browser object: it launches Playwright's Chromium, connects over CDP with `--cdp=URL` (and `CDP_AUTHORIZATION` for a hosted service), or takes a browser from a caller through `renderAll(browser, jobs, src)`. The `figures.yml` workflow runs it on GitHub's runners: pushes and pull requests that touch `docs/` fail on a stale SVG and upload the renders as an artifact; a manual run with `commit` set commits them from a separate job that alone has write access.
- **Mermaid 11.17.2, not mermaid-cli, and not an npm dependency.** mermaid-cli adds Puppeteer and a Chrome download to every `npm ci` while the repository already carries Playwright, and it opens its page from a local file that a remote browser cannot reach. A pinned URL with integrity adds no package at all. 11.17.2 is the newest 11.x release older than two weeks and outside every published advisory range (all fixed by 11.16.1); 12.2.0 was tried and breaks hyphenated labels such as `modootoday-check` inside the node at about 120 px, which 11.x does not. The docs site's built-in loader example stays on the 11 line too.

## Consequences

The docs' own diagrams cannot drift from their fences: the docs QA job already runs the full check, and the Figures workflow names and renders the stale ones. Sites get the same check and the list for their hooks with no new requirement; they render with the Mermaid CLI or a copy of the script. Renders differ slightly between browser and font versions, so freshness is judged by digest, never by comparing SVG bytes. A Mermaid upgrade is one edit to the URL and hash and leaves existing SVGs valid until their fences change; to restyle every diagram, render them all again.
