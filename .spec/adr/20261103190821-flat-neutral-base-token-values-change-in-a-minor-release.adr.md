---
id: adr:modootoday/20261103190821
title: "Flat neutral base: token values change in a minor release"
status: active
created: 2026-11-03T19:08:21Z
updated: 2026-11-03T19:08:41Z
rel:
  governs: [_sass/modootoday/tokens]
---

# Flat neutral base: token values change in a minor release

## Context

The default look used a blue-tinted gray ramp, soft shadows on cards, buttons and pager links, a translucent blurred header and tinted, striped callouts. The theme's default is meant to be one flat, neutral system that every layout and every later preset builds on: hairline borders, solid surfaces, neutral grays and one accent for links, focus and active states. The core sheet has 393 B of headroom under its 27,648 B budget, and the type and header work that follows needs bytes, so the savings have to come first.

## Decision

- Token names do not change; their values do. The gray primitives become a neutral ramp (#fafafa to #0a0a0a). Light text is #171717, muted text #6b6b6b (5.33:1 on white, 4.89:1 on the #f5f5f5 hover fill), the light hairline #e5e5e5.
- Dark mode has three layers: page #0a0a0a, cards and muted surfaces #171717, the hover fill #262626. The dark hairline is #2e2e2e, not #262626: on #171717 cards #262626 measures 1.18:1, under the 1.2:1 floor the contrast audit applies to `border`, while #2e2e2e measures 1.32:1 (1.46:1 on the page). It keeps the `gray-700` slot, which already held the dark hairline, so no primitive is added or retired for it.
- `shadow-sm` is `none` in both schemes; `shadow` stays as one soft overlay shadow for menus and search results. Components drop their own shadows, the header blur, the title mark's inset ring, the callout tint and stripe, the 2px key bottom and the button press transform.
- New semantic tokens: `border-input` (#8a8a8a light, #737373 dark: at least 3:1 on the page and 3.78:1 on dark cards), the border for form fields, and `narrow` (40rem), the reading width for short single-column pages. The checker's token list and `tokens.json` take them from the maps.
- Base values: heading weight 600, line height 1.75, `measure` 45rem, `container` 75rem, `header-height` 4rem, `space-section` 4rem. The dark `theme_color` default follows the page to #0a0a0a.
- `--mt-p-space-3` is unused by the theme from now on. Removing a published custom property breaks sites, so it stays in the core sheet until the next major version.
- The release that carries this is a minor one. The Migrate and upgrade guide gives a token bridge snippet with the 1.4 values, so a site can keep the previous colours, sizes and shadows; the removed blur, stripe and lift come back only through the site's own sheet.

## Consequences

Every page looks different, so the visual baselines change wholesale once; the next commits are reviewed against this one. The core sheet shrinks (measured with the classic builder in the commit that lands this), which pays for the type scale and per-language font stacks. Sites that set colour tokens keep their values; sites that relied on the default palette see the new one unless they paste the snippet. The docs QA adds `border-input` on the background (3:1), `border` on `card` (1.2:1) and `muted-foreground` on `accent` (4.5:1) to the token contrast pairs.
