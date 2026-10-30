---
id: adr:modootoday/20261030090000
title: Screen-reader audit and authoring rules
status: active
created: 2026-10-30T09:00:00Z
updated: 2026-10-30T09:00:00Z
---

# Screen-reader audit and authoring rules

- Status: accepted
- Date: 2026-10-30

## Context

The kit targets WCAG 2.2 AA. Blind and low-vision users depend on landmarks, heading order, accessible names,
live announcements and reflow. NVDA, JAWS and VoiceOver cannot run in CI or on the build box.

## Decision

1. `qa/a11y.mjs` audits **every** built page of the docs site, the example site and the blog/news sample:
   axe-core (WCAG 2.0-2.2 A/AA tags) plus `qa/audit/screen-reader/sr-structure.mjs` (lang/dir, title, one `main`, labelled navs,
   working skip link, one h1, heading skips in `main`, duplicate ids, SVG hidden or `role=img`, table headers,
   `img` alt, vague link text, unnamed controls, live regions next to search and copy), `sr-reflow.mjs`
   (1.4.10 at 320 px, 1.4.4 at 200 % text, 1.4.12 text spacing) with reduced motion on.
2. The screen-reader stand-in is Playwright's accessibility-tree snapshot (`sr-tree.mjs`), one YAML per page, reviewed
   for reading order and names. This is documented as a limit: real AT announcements are not verified.
3. Search results get `aria-live="polite"` in the layout (no JS bytes). A spoken result count would need JS and waits
   for the core JS budget split.
4. `lib/modootoday/check/a11y/content.rb` adds authoring rules: errors for `<img>` without alt, empty links and
   duplicate ids; warnings for empty Markdown alt, vague link text and heading skips. It lives in a context
   subdirectory because `check/` is over the 12-file limit.
5. Table captions are not required: GFM tables cannot carry one; authors introduce tables with a heading or sentence.

## Consequences

`node qa/a11y.mjs OUT SITE...` must report 0 problems before release. Findings at the time of writing are in the
CHANGELOG entry.
