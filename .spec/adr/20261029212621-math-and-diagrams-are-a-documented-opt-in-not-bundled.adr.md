---
id: adr:modootoday/20261029212621
title: "Math and diagrams are a documented opt-in, not bundled"
status: active
created: 2026-10-29T21:26:19Z
updated: 2026-10-29T21:26:19Z
rel:
  governs: [docs/recipes/math-diagrams.md]
---

# Math and diagrams are a documented opt-in, not bundled

## Context

Math and diagram fences render on github.com but not on a Jekyll site. Bundling MathJax, KaTeX or Mermaid would break the size budget and the strict CSP (Mermaid injects style elements) and tie the theme to their release cycles.

## Decision

The theme bundles no renderer. A docs guide (Math and diagrams, en and ko) documents two opt-in paths compatible with default-src 'self': render at build time and commit SVG/HTML (recommended), or self-host KaTeX/Mermaid and load them from _includes/footer-custom.html on pages that opt in through front matter. CDNs are discouraged. Mermaid in the browser requires style-src 'unsafe-inline' and securityLevel strict, and the guide says so.

## Consequences

The theme stays small and CSP-strict by default; sites that need math or diagrams take on the renderer themselves. The Markdown source stays the source of truth for github.com and the Markdown twins.
