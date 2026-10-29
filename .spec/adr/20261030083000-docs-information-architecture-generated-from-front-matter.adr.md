---
id: adr:modootoday/20261030083000
title: Docs IA - context sections, nav and indexes generated from front matter
status: active
created: 2026-10-29T23:30:00Z
updated: 2026-10-29T23:30:00Z
rel:
  governs: [docs/_data/sections.yml, script/docs-index, script/docs/tree.rb, script/docs/outputs.rb, qa/docs/structure.rb, docs/_data/nav/main.yml, docs/_data/nav/main-ko.yml, docs/_data/nav/main-ja.yml, _includes/modootoday/doc/sidebar.html, _includes/modootoday/doc/sidebar-item.html, docs/_includes/docs/examples.html]
---

# Docs IA: context sections, nav and indexes generated from front matter

## Context

The docs grew as flat files in docs/ (plus ko/, ja/) with three hand-edited nav files. Around 30 more components and 30 more layouts are planned; a flat tree and hand-kept nav, index lists and .md.txt twins drift and do not scale.

## Decision

- Five sections by reader context: guides/, components/, layouts/, recipes/, reference/ (listed with en/ko/ja titles in docs/_data/sections.yml). Root keeps only index, 404, tags, categories (tags/categories are listed under Reference via `nav_section: reference`). blog/, news/, authors/ are live sample sites, not docs, and are exempt.
- Depth is at most section/group/page; a group is a subdirectory with its own index.md.
- Page front matter is the single source of truth: `title`, `description`, integer `nav_order` (or `nav_exclude: true`), optional `nav_title`. `ruby script/docs-index` generates the three nav files, the page list between `<!-- spec:docs-index:begin/end -->` in each section index, and every .md.txt twin; `--check` fails when any is stale.
- English is canonical. ko/ja pages mirror English paths; a missing translation falls back to the English page in nav and indexes; a ko/ja page without an English page is an error.
- Sidebar: groups are `<details>`, open only on the group holding the current page; at most 12 entries per group.
- Example pairing lives in one shared include (docs/_includes/docs/examples.html); the examples layout only includes it.
- qa/docs/structure.rb runs in CI and fails on any rule above, on banned version wording in user docs, and on more than 12 authored files per directory (generated twins are not counted).

## Consequences

New pages need only a file in the right section plus front matter, then `ruby script/docs-index`. Old root URLs (/install/ etc.) changed; links in README, CHANGELOG, QA and tests were updated. Older ADRs keep their historical docs/*.md paths.
