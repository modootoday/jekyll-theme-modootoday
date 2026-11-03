---
id: adr:modootoday/20261103012842
title: The toggle announces mt:themechange; site modules read the scheme and settings through two small theme modules
status: active
created: 2026-11-03T01:28:42Z
updated: 2026-11-03T01:43:23Z
rel:
  governs: [assets/js/modootoday/theme, assets/js/modootoday/dom, assets/js/modootoday/theme-toggle.js]
---

# The toggle announces mt:themechange; site modules read the scheme and settings through two small theme modules

## Context

A module that draws a hero, a chart or a widget has to repaint when the reader switches between light and dark. The only signal was the `data-theme` attribute, which a module could watch with a `MutationObserver` (the Mermaid loader does), and which never changes on a site without the toggle. Module scripts also have no `document.currentScript`, so they cannot read settings from their own tag.

## Decision

- `theme-toggle.js`, rewritten one statement per line with its behaviour kept, dispatches `mt:themechange` on `document` with `detail: {theme, source}`: `source: "toggle"` after a click, `source: "system"` after a change of the system scheme while no scheme is chosen (no `data-theme`). It is not sent on the first paint.
- `assets/js/modootoday/theme/current.js` exports `currentTheme()` (`data-theme`, else the system setting) and `onThemeChange(callback)`, which listens to the event and to the `prefers-color-scheme` query, so it also works on sites without the toggle, and calls back only when the scheme really changed (the toggle and the query can both fire for one change). It returns a function that removes both listeners.
- `assets/js/modootoday/dom/config.js` exports `readConfig(element, defaults)`: the defaults name the `data-*` keys and give their types (a boolean is on when present; numbers and JSON keep the default when they do not parse).
- Both are ES modules that no theme page loads by itself; a site module imports them by relative path. They are public API. The Mermaid loader keeps its observer.

## Consequences

Later theme modules (charts, widgets, filter) reuse the same two helpers. Their bytes count in the core script total (see the budget ADR of the same day).
