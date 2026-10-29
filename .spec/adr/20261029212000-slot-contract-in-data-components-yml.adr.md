---
id: adr:modootoday/20261029212000
title: Slot contract in _data/components.yml
status: active
created: 2026-10-29T21:20:00Z
updated: 2026-10-29T21:42:35Z
rel:
  governs: [exe/modootoday-check]
---

# Slot contract in _data/components.yml

## Context

The registry in _data/components.yml only checked section parameters and i18n keys. Authors had no stable names for the parts of a section that each component consumes (card items, tab panels, CTA links), and the docs listed a slot contract as future work. The theme must keep working on github-pages (Jekyll 3.10, Liquid only) and Jekyll 4, and existing markup must not change.

## Decision

A slot is a named, structural part of a section's Markdown after its ## heading. The fixed vocabulary is lead (plain paragraphs before the first list, ###, code block or quote), items (list items), panels (### headings), actions (link-only lines), code (fenced code blocks) and figures (lines starting with an image). A component entry may declare slots: {name: {required, min, max}}; required: true means min: 1. modootoday-check counts each declared slot per section and fails on counts outside the range and on unknown slot names. The contract is enforced only by the checker (no Liquid or markup changes), so it works the same on github-pages and Jekyll 4. Components without slots: are not counted. Slot names follow the public API deprecation policy.

## Consequences

Existing registries and pages keep working unchanged. The docs and example registries declare slots, so CI exercises the contract. Adding a slot name is a minor change; renaming or removing one needs a deprecation of at least one minor. Detection is line-based like the sections: count check, so content inside code fences and comments is ignored, while unusual Markdown (for example HTML blocks) is not counted.

## Amendment: registry validation, alternative forms and parts

The checker also validates the registry itself, once per registry: a component entry accepts only params, i18n, slots and parts; a slot rule accepts only required, min and max; min and max are whole numbers with min not above max. Unknown keys are errors rather than silently ignored, because a misspelt key (for example mni) would otherwise disable a rule without notice. Components such as steps and timeline have two valid shapes (a list or ### panels), so slots: may be a list of at least two alternative forms; a section passes when it satisfies any one, and the error names every form that failed. A single map keeps its previous meaning, so existing slot declarations are unaffected. We chose a plain list over a oneOf/anyOf keyword to keep the YAML short and the meaning fixed (any one form). parts: lists the stable selectors a component promises to keep; when the site has an api.md with a Component structure table, every part must appear there in backticks, so the registry and the documented API cannot drift. The docs registry declares parts for every section component.
