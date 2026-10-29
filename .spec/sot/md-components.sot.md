---
id: sot:modootoday/md-components
title: md-components v1 rules
status: active
created: 2026-10-29T20:10:48Z
updated: 2026-10-29T21:18:54Z
verify: [bundle exec rake]
rel:
  governs: [_includes, exe, _layouts, test]
---

# md-components v1 rules

## Rule


RULES.md (header `md-components v1`, final) is the user-facing text; this sot is the judging rule set. Summary by RULES.md section:
- §0 every content page has front matter.
- §1 core components: top-level alerts `> [!TYPE]` (5 types, any case); sections split only on top-level `##` with explicit `sections:` mapping (count must match); card grid, CTA, tabs, mermaid, tables; decoration only from front matter/layouts.
- §2 optional: status badges (fixed set), `_data/components.yml` registry.
- §3 chrome strings in `_data/i18n/<lang>.yml`, English fallback.
- §4 forbidden outside code: raw HTML, Liquid, bare autolinks, abbreviations, HTML comments, setext/nested/indented/commented `##`, multi-word fence info strings; footnotes allowed.
- §5 checker `modootoday-check SRC SITE [--twins] [--github-pages[=VER]] [--strict] [--gh]`.
- §5a twins `/<name>/index.md` byte-identical to the body; per-language `llms.txt`/`llms-full.txt`.
- §6 known limits (`##` inside alerts/quotes/lists stays an error).

## Why

Bodies must render the same on github.com, in kramdown (GitHub Pages and Jekyll 4) and as plain-text twins for agents. Measured on GitHub's renderer, kramdown 2.4 and CommonMark parsers: alerts are a GitHub extension outside GFM and only top-level alerts render; nested `##` breaks section splitting. Decisions: [[adr:modootoday/20261029201117]] (alerts, ##), [[adr:modootoday/20261029201116]] (twins, llms). v1 was approved by the maintainer on 2026-10-30; the status is final.

## Verification

`bundle exec rake` on `gemfiles/github-pages.gemfile` and `gemfiles/jekyll4.gemfile` (unit, fixture and consumer builds, then `modootoday-check example example/_site --twins`); `npm test` for tabs JS.
