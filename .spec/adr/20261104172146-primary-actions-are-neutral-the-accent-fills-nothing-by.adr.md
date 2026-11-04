---
id: adr:modootoday/20261104172146
title: Primary actions are neutral; the accent fills nothing by default
status: active
created: 2026-11-04T17:21:46Z
updated: 2026-11-04T17:22:05Z
rel:
  governs: [_sass/modootoday/kit, _sass/modootoday/components/core/inline/_cta.scss]
---

# Primary actions are neutral; the accent fills nothing by default

## Context

The flat base (adr:modootoday/20261104011121) limits the accent colour to links, focus and the active state. The primary action of a hero or `c: cta` button row, and the first button of the marketing and detail layouts, was still filled with `primary`, so every landing page carried a large block of accent. Sites that want the old look, and the planned `product` preset, need a way back that does not mean overriding three selectors.

## Decision

- The primary action is filled with `foreground` and lettered in `background`, read through two hooks, `--mt-button-primary-bg` and `--mt-button-primary-fg` (defaults `var(--mt-foreground)` and `var(--mt-background)` in `registry/_hooks.scss`). The theme never declares them; a site or a preset sets them.
- The CTA rows (`components/core/inline/_cta.scss`) and the bundle buttons (`kit/_button.scss`) share the metrics: 40px tall (48px in a hero), 1rem side padding (1.5rem in a hero), 14/20 at weight 500, `radius` corners. Hover mixes the fill 90% with the background instead of lifting the button.
- Every layout bundle imports the type scale and the hook map, so bundle partials use `mt-size()` and `mt-hook()` as the context sheets do.

## Consequences

Accent-filled buttons come back with one rule, `:root { --mt-button-primary-bg: var(--mt-primary); --mt-button-primary-fg: var(--mt-primary-foreground); }`, which the upgrade guide quotes. In forced colours the button keeps its border. The hooks are listed in the Customize guide's hook table, which a test compares with `registry/_hooks.scss`.
