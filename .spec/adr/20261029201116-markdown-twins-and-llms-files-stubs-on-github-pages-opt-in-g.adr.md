---
id: adr:modootoday/20261029201116
title: "Markdown twins and llms files: stubs on GitHub Pages, opt-in generator elsewhere"
status: active
created: 2026-10-29T20:11:13Z
updated: 2026-10-29T20:11:20Z
rel:
  governs: [lib]
---

# Markdown twins and llms files: stubs on GitHub Pages, opt-in generator elsewhere

## Context

Agents want each page as raw Markdown (`/<name>/index.md`) and per-language `llms.txt`/`llms-full.txt`. Classic GitHub Pages (Jekyll 3.10, safe mode) runs only whitelisted plugins, and Liquid cannot create output files, so per-page outputs need a source file.

## Decision

Twin layout `twin` + one-file stub `<name>.md.txt` works everywhere; layouts `llms`/`llms-full` generate the llms files from front-matter-only stubs. Opt-in `plugins: [jekyll-theme-modootoday]` (Jekyll 4 / Actions builds) adds the same pages virtually; output is byte-identical to the stub build; stubs win; `twin: false` opts out. The checker `--twins` verifies the result, not the method.

## Consequences

Classic Pages users keep one stub per page. Checker assumes directory URLs; collections are not covered; bodies must stay Liquid-free.
