---
id: adr:modootoday/20261104223512
title: A doc page's call to action keeps the section rule and narrow disclosures take the sidebar chevron
status: active
created: 2026-11-04T22:35:12Z
updated: 2026-11-04T22:35:43Z
rel:
  governs: [_sass/modootoday/base/_prose.scss, _sass/modootoday/components/doc/_sidebar.scss]
---

# A doc page's call to action keeps the section rule and narrow disclosures take the sidebar chevron

## Context

The visual review of the 1.5.0 candidate, round 2, found two leftovers of earlier changes. The call to action became flat, but `.mt-doc .mt-section + .mt-section:not(.mt-cta)` still left it out of the section rhythm, so it kept the plain section's 4rem top padding plus its own 4rem margin and no hairline: "Start now" sat about twice as far from the section above as any other section. The sidebar group titles took a CSS chevron, while the Guides and On this page disclosures below 64rem kept the native triangle.

## Decision

- In a doc page, a `c: cta` section follows the same rule as every other section: the top hairline, 3.25rem above and 2rem inside. Landing and marketing pages keep their centred call to action.
- The narrow-screen sidebar and table-of-contents summaries drop the native marker and use the sidebar's chevron at the end: it points to the end when closed, down when open, and is mirrored in RTL. The chevron is a border, so forced colours keep it.

## Consequences

The core sheet loses a selector; the doc sheet grows by a few bytes within its cap. Doc pages now have one disclosure marker at every width.
