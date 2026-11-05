---
id: adr:modootoday/20261105075445
title: "Committed static figures keep renderers out of the theme, and one digest rule ties each render to its fence"
status: active
created: 2026-11-05T07:54:45Z
updated: 2026-11-05T07:55:34Z
rel:
  governs: [_includes/modootoday/markdown/figures, lib/modootoday/figures.rb]
  depends_on: [adr:modootoday/20261029212621]
---

# Committed static figures keep renderers out of the theme, and one digest rule ties each render to its fence

## Context

adr:modootoday/20261029212621 keeps every renderer out of the theme and recommends rendering at build time, but the theme offered nothing for that path: an author referenced one SVG as an image figure, the theme darkened it with a filter, and nothing tied the SVG to the Mermaid source it was drawn from. The GitHub Pages build runs no scripts, so a render step cannot live in the build either.

## Decision

- **Static figures are renders the site commits; the theme shows them in place of the fence.** The theme still bundles and runs no renderer, so this amends adr:modootoday/20261029212621 only by making the build-time path a theme feature.
- **Diagrams are listed by position.** Front matter `diagrams: [{name, alt, caption, width, height}]`: the n-th ```` ```mermaid ```` fence of the page is the n-th entry. The fence stays plain GFM (RULES 1a allows one info word, so the fence carries no name), github.com still draws it, and the Markdown twin keeps it.
- **One transform for every layout.** `_includes/modootoday/markdown/figures.html` (the assembler; its parts in `markdown/figures/`) runs from `links/content.html` only on pages with the list, so other pages build unchanged. A fence becomes `figure.mt-figure.mt-figure-svg.mt-diagram` with the light SVG and, with `modootoday.diagrams.dark` (default true), the `.dark.svg` twin; the fence moves into `details.mt-diagram-source` unless `source: none`. A fence without an entry stays a code block. The Mermaid loader skips a page with the list.
- **The pair swaps in CSS, by the token emit's selectors** (the system scheme unless the page is forced light, and `[data-theme=dark]`), so it follows the toggle; `<picture media>` cannot. Both images carry the alt text and CSS hides one with `display: none`, which removes it from the accessibility tree; an empty-alt, `aria-hidden` dark image would leave a dark page with no text alternative. Both carry `.mt-no-filter`; a lone image (`dark: false`) keeps the SVG figure's dark filter. The rules are part `media/diagram` of the figure row (component `diagram`), not a sheet of their own.
- **One digest rule.** `data-mt-src="sha256-<hex>"` on an SVG's root records its fence: SHA-256 of the fence body (the lines between the fence lines) with CRLF and CR as LF and the trailing newlines removed. `Modootoday::Figures.digest` in `lib/modootoday/figures.rb` owns it; the checker, the stale-figure check and the static math blocks planned for 1.6 use it, and any script that writes the attribute is pinned to it by a parity test.
- **RULES.md additions in 1.6.0 keep the `md-components v1` header**, as 1.1.0 did; the CHANGELOG lists the changed rows under Rules.

## Consequences

Diagrams work without JavaScript and under `style-src 'self'`, since each SVG is an image. Authors render each fence twice and commit both files; until the stale-figure check lands, an edited fence with an old SVG goes unnoticed. An SVG with Mermaid's inline `<style>` opened on its own breaks under a strict edge CSP; the recipe documents the exemption. The figure sheet grows by the swap rules, 79 bytes gzip, and stays under its 896-byte cap.
