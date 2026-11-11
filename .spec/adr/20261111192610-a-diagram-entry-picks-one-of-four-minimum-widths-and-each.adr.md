---
id: adr:modootoday/20261111192610
title: "A diagram entry picks one of four minimum widths, and each language draws its own pair"
status: active
created: 2026-11-11T19:26:10Z
updated: 2026-11-11T19:26:36Z
rel:
  governs: [_includes/modootoday/markdown/figures/diagrams.html, _sass/modootoday/components/media/_diagram.scss, lib/modootoday/check/page/figures/diagrams.rb]
  depends_on: [adr:modootoday/20261109141321]
---

# A diagram entry picks one of four minimum widths, and each language draws its own pair

## Context

The 1.6.0 usability audit deferred two diagram findings to 1.7 (A12 and A13 in [[adr:modootoday/20261109141321]]): V2, the 818 x 63 docs flowchart drawn at the 32rem figure minimum shows its text at about 10 px in a 360 px column, and V1, the SVG text stays English on the ko and ja pages. A strict CSP rules out a `style` attribute, so a per-diagram width cannot be a free value written on the element.

## Decision

- A `diagrams:` entry takes `min_width`, one of 24, 32, 40 or 48 (rem). The include adds `mt-figure-min-<n>` to the figure, and the figure sheet has one rule per step that sets `--mt-figure-min-width`. `modootoday-check` owns the list of steps and reports any other value; the sheet is pinned to the same four by a theme test. No entry keeps the 32rem default and its output.
- One SVG pair per language: a translated page writes its fence in its language and lists its own entry (`recipes/flow-ko`, `recipes/flow-ja` in the docs). The checker already compares each entry with its own fence; a translation that keeps the English fence keeps sharing the English pair. The new pairs are rendered by the Figures workflow like any other.
- The docs recipe and the ko and ja kitchen sinks use the per-language pairs; the recipe's diagram uses `min_width: 48` in all three languages.
- The figure sheet's cap rises from 896 to 1024 B gzip, as planned for A12 (planning measurement 819 B before this change).

## Consequences

- The recipe's flowchart keeps readable text at 360 px and scrolls sideways; the ko and ja pages show translated node labels.
- The entry key list in the API and rules reference gains `min_width`.
- A site that wants a free width keeps overriding `--mt-figure-min-width` in its own stylesheet, as before.
