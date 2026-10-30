---
id: adr:modootoday/20261029231339
title: Content component scope for 1.0 and per-component stylesheets
status: active
created: 2026-10-29T23:13:39Z
updated: 2026-10-29T23:13:39Z
---

# Content component scope for 1.0 and per-component stylesheets

## Context

The kit is compared with app UI libraries such as shadcn/ui and Tailwind Plus, which ship many more components. The kit is a Markdown-first, Liquid-only, CSP-strict content theme whose peers are documentation and blog themes. The single CSS bundle is close to its 32,768 B compressed budget.

## Decision

- In scope: content components authored in plain Markdown that degrade to readable Markdown elsewhere: callout variants (GitHub alert syntax), code titles, line highlight and diff, file tree, link cards, details, description lists and parameter tables, quotes, image gallery and responsive embeds, FAQ, pricing and comparison, announcement banner and back-to-top, author card, related posts and share links, footnotes, progress, a static subscribe form, changelog entries, a comments hook and a tag cloud.
- Out of scope: app UI needing runtime state or focus-trapping scripts: form controls, dialogs and sheets, dropdown and context menus, toasts, interactive data tables, command palettes, carousels, charts and calendars.
- Section components move to optional per-component stylesheets loaded only by pages whose sections use them; the core bundle keeps tokens, base, chrome and inline components. Budgets: core 24 KB, each component 2 KB, any page 32 KB. A bundle option keeps one file.

## Consequences

New components fit without breaking the budget and pages load less CSS. Each new component needs an example, a slot entry, checker rules, localized strings and QA coverage.

## Addendum: loading and skeleton UI

Loading indicators and skeleton placeholders are base components in 1.0: `loading:spinner`, `loading:bar`, and `skeleton:` with text, card, image, avatar and row variants, plus `.mt-ratio-*` reserved aspect ratios. They are CSS-only, honour reduced motion, forced colors and RTL, and announce a `loading.label` status. Their styles live in an optional `loading` sheet that only pages using them (or sites with `modootoday.loading: true`) link.
