---
id: adr:modootoday/20261029233000
title: Accessibility baseline - safe areas, keyboard model, forced colors, per-bundle budgets
status: active
created: 2026-10-29T23:30:00Z
updated: 2026-10-29T23:30:00Z
rel:
  governs: [_sass/modootoday/layout/_safe-area.scss, _sass/modootoday/_access.scss, _sass/modootoday/base/_interaction.scss, assets/js/modootoday/search-keys.js, assets/js/modootoday/scroll-region.js, _includes/modootoday/theme-color.html, docs/accessibility.md]
---

# Accessibility baseline: safe areas, keyboard model, forced colors, per-bundle budgets

## Context

1.0 must meet WCAG 2.2 AA without setup, including iOS notched devices and keyboard-only use. The core CSS bundle has a 32 KiB budget and the core JS bundle 10 KiB, both nearly full.

## Decision

- **Safe areas:** the default viewport is `viewport-fit=cover`; `modootoday.viewport_fit: auto` opts out. Insets are exposed once as `--mt-safe-top|right|bottom|left` (`env(safe-area-inset-*)`, wrapped in `unquote` for Ruby Sass 3.7) and consumed by the shell (header top, side gutters via `--mt-gutter`, footer bottom), skip link and menus. Sites and tests override the variables, never `env()` directly.
- **theme-color:** `modootoday/theme-color.html` emits light/dark `theme-color` meta matching `--mt-background`; `modootoday.theme_color` takes one hex, `{light, dark}` or `false`.
- **Keyboard model:** `/` (outside fields) and `Ctrl`/`Cmd`+`K` focus search; `ArrowDown`/`ArrowUp` move through results and back to the input; `Esc` leaves results or clears. Tabs: `ArrowLeft`/`ArrowRight` (mirrored in RTL), `Home`, `End`. Menus (`menu.js`): arrows, `Esc` returns focus. Overflowing `pre` and `table` get `tabindex=0`, `role=region` and a localized label (`code.label`, `table.label`) via `scroll-region.js`, removed again when they stop overflowing. Focus rings inside `[tabindex="0"]` are inset.
- **Forced colors and motion:** under `forced-colors: active`, icon buttons and the search input get `ButtonText` borders; `prefers-reduced-motion: reduce` disables transitions and animations. Coarse pointers get 44 px targets and 16 px search text. These overrides live in `_access.scss`, imported after components.
- **search-keys.js split:** the shortcuts live in their own file next to `search.js` so the search bundle stays within the JS budget and the shortcut code is single-purpose.

## Consequences

- Core CSS is 32,762 of 32,768 B (6 B headroom) after trimming; core JS is at its limit. Further features cannot fit the core bundle.
- Recommendation: replace the single budget with per-bundle budgets - a core budget (layout, tokens, shared components, a11y) kept at the current numbers, and separate budgets for optional bundles (per-component CSS from the component-CSS-split work, blog/news, doc-only scripts) loaded only on pages that use them. The QA budget check should report each bundle. To be decided together with the component CSS split landing in parallel.
- Keyboard and mobile behaviour is checked by `qa/audit/keyboard.mjs` and `qa/audit/mobile.mjs`.
