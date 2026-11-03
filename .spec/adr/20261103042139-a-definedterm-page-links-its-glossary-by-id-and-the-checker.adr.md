---
id: adr:modootoday/20261103042139
title: A DefinedTerm page links its glossary by @id and the checker follows the link
status: active
created: 2026-11-03T04:21:38Z
updated: 2026-11-03T04:22:05Z
rel:
  governs: [lib/modootoday/check/build]
---

# A DefinedTerm page links its glossary by @id and the checker follows the link

## Context

A glossary page prints one `DefinedTermSet` (`<page>#main`) with a `DefinedTerm` per entry. Sites that give a term its own page, and pages that are learning material rather than courses, had no type of their own. The course properties lived only in the `Course` branch of `docs-extra/jsonld.html`.

## Decision

- `schema: {type: DefinedTerm}` makes the page's main entity a term. `term_set:` with a site path prints `inDefinedTermSet` as `{"@id": "<absolute path>#main"}`, the glossary's own node, so the two pages form one graph; an absolute URL is printed as a plain URL. `term_code:` prints `termCode` as text. A glossary entry's `url:` adds that term page's URL.
- `LearningResource` is set with `schema.type` or `schema.layouts`. `jsonld/schema/learning.html` holds the course properties (provider, `educationalLevel`, `timeRequired`, `teaches`, `learningResourceType`) for both types; `Course` keeps `syllabusSections`. A course without the new keys prints the same bytes.
- The checker's new build rule `TermSets` resolves a `DefinedTerm`'s in-site `inDefinedTermSet` against the page's own `WebSite` URL and requires a built page whose graph has a `DefinedTermSet` with that `@id`. A term set on another site is not followed.
- `StructuredData` walks nested nodes only inside arrays, so a single nested `acceptedAnswer` is never checked. Rather than widen the walk (which would newly judge every single nested node, such as an event's `offers` without a price, on existing sites), a `Question` gets its own rule: an empty answer is an error.
- `modootoday.schema` is registered in the config schema as `false` or a map; only `faq` is judged (`auto` or `false`), so existing keys and unknown ones stay as before.

## Consequences

`LearningResource` has `name` as required and `educationalLevel`, `learningResourceType`, `timeRequired` as recommended. Whether the walk should cover single nested nodes is left as a separate change.
