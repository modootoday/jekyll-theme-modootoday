---
id: adr:modootoday/20261104223511
title: The skip link lands on the doc text column past the sidebar
status: active
created: 2026-11-04T22:35:11Z
updated: 2026-11-04T22:35:43Z
rel:
  governs: [_layouts/doc.html, _layouts/default.html]
---

# The skip link lands on the doc text column past the sidebar

## Context

"Skip to content" moved focus to `main`, but on a doc page `main` starts with the sidebar, so the next Tab stops were its group titles and links, eight on the docs site, before the breadcrumb and the text (audit:modootoday/20261104220950, m8). The link skipped the header only.

## Decision

- On a page with a sidebar, `doc.html` gives the text column (`div.mt-doc-main`) `id="mt-content"` and `tabindex="-1"`, and `default.html` points the skip link at `#mt-content` when the page has it, else at `#mt-main` as before.
- Like `main`, the column shows no focus ring when it takes focus from the skip link.
- The two doc columns keep their `aside` elements and public class names but take `role="none"`: each holds a named `nav` (the sidebar, On this page), and as two unnamed complementary landmarks they failed axe `landmark-unique` beside them.
- The docs QA keyboard check accepts either target; Accessibility says the link lands past the sidebar.

## Consequences

The first Tab after the skip link reaches the breadcrumb on a wide screen, and the folded Guides disclosure below 64rem. Pages without a sidebar are unchanged.
