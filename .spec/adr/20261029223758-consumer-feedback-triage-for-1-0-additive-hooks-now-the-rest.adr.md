---
id: adr:modootoday/20261029223758
title: "Consumer feedback triage for 1.0: additive hooks now, the rest deferred"
status: draft
created: 2026-10-29T22:37:58Z
updated: 2026-10-30T00:00:00Z
---

# Consumer feedback triage for 1.0: additive hooks now, the rest deferred

## Context

Two sites built on the theme before 1.0 sent findings (twelve and ten). Until 1.0.0 is tagged, changes that fix a reported issue may also change existing behavior.

## Decision

- Added in 1.0: `visual:` on section items and `hero:` for a site-provided `_includes/sections/<name>.html`; `full_width:` front matter; `modootoday.hreflang` independent of `seo`; checker validation of these keys; a clearer message when `--github-pages` finds no lockfile; a home `short_title:` for the first breadcrumb; a documented checker exception for tool region markers (`<!-- tool:name:begin -->` / `:end -->`) alone on a line. The hero `visual:` also answers the request for a hero media hook.
- Documented, no code change: overriding tokens against the dark-scheme selectors (`tokens`/`tokens_dark` or `css_layers: true`), the exact `sections:` count for pages written against pre-1.0 drafts, `twin_of` being relative to the stub file, and localizing the tabs label with `tabs.label` in `_data/i18n`.
- Handled in other planned work: a logo slot, site icons and a theme toggle label that follows its state and language (brand and icons work); a single source for the language list (i18n work).
- Shipped in 1.0 (not additive; allowed because 1.0.0 is not yet tagged): a doc sidebar built from nav groups (`modootoday.sidebar: auto | true | false`, on by default when the nav has groups; a collapsed `<details>` menu below 64rem instead of a scrolling link row); previous/next links that walk the nav file in order, a group's own page then its items; `color_scheme: auto-dark | auto-light`, which prints the starting scheme in the HTML and keeps the toggle, so no `head-custom.html` script and no flash; page actions on pages with a Markdown twin (View as Markdown, Copy page, Copy for AI; `modootoday.page_actions` and front matter `page_actions: false`), with labels in the theme's 23 i18n catalogs and the script folded into `code-copy.js` to stay inside the JS budget.
- Dropped: a switch to omit the `md-*` alias CSS, because the aliases are being removed before 1.0.
- No change: references to an old docs path were not found in the theme.

## Consequences

Doc-only includes moved to `_includes/modootoday/doc/`. New keys follow the 1.x stability rules from 1.0. Deferred items need their own changes and appear in the changelog when they ship.
