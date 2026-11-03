---
id: adr:modootoday/20261103042138
title: "FAQPage structured data is read back from the rendered c: faq sections"
status: active
created: 2026-11-03T04:21:38Z
updated: 2026-11-03T04:22:05Z
rel:
  governs: [_includes/modootoday/jsonld]
---

# FAQPage structured data is read back from the rendered c: faq sections

## Context

An `FAQPage` needed a hand-written `schema: {mainEntity: [...]}` that repeated every question and answer of the page's `c: faq` section. Search engines require the structured data to match the visible text, and two copies drift. The JSON-LD graph is printed in `<head>` of the default layout, where `content` already holds the rendered body with its sections.

## Decision

- `modootoday.schema.faq: auto` (every page) or front matter `schema: {faq: auto}` (one page; `faq: false` opts out) turns it on. Off by default, so pages without the key build byte-identical HTML.
- Type order: front matter `schema.type`, then `FAQPage` when the setting is on and `sections:` has a `c: faq` item, then `schema.layouts`, then the layout map. An explicit type wins; a doc page with an FAQ section stops being a `TechArticle`.
- `jsonld/schema/faq.html` splits `content` on `<section class="mt-section mt-c-faq` up to its `</section>`, then on `details.mt-details`: the summary is the `Question` name, the rest of that details the `Answer` text. `c: details` sections are not read. Both go through `strip_html` and `normalize_whitespace`, and the five entities kramdown writes (`&lt;`, `&gt;`, `&quot;`, `&#39;`, `&amp;`) are decoded, so the text equals the element's textContent.
- `<pre>` blocks are dropped from answers: code is not prose and would bloat the answer.
- `schema.mainEntity` in front matter still wins; the `faq` key is never printed as a property.
- A setting with a `c: faq` section and no question prints an empty `mainEntity`, which `modootoday-check` rejects.

## Consequences

The answer text is plain text, without links or lists as HTML. A test builds pages and compares every question and answer with the textContent of the built details. The docs Components page turns it on.
