---
nav_order: 50
title: Roadmap
description: What the theme supports, which stacks it runs on, and where it is heading.
---
# Roadmap

## Supported in 1.0

- Components in light and dark: alerts, sections, cards, buttons, tabs, badges, tables, accordion, steps, figures, timeline, keyboard keys, breadcrumb, table of contents, theme toggle and search. See [Components](../../components/).
- Final content rules (`md-components v1`) and a stable [public API](../api/).
- Canonical, `hreflang` and Open Graph tags by default; sitemap and feed when you add the plugins.
- A language switcher for multilingual sites, and right-to-left scripts (see the [RTL kitchen sink](../../components/kitchen-sink-rtl/)).
- A slot contract for your own `_data/components.yml` ([API](../api/#slot-contract)).
- Markdown twins and `llms.txt` for AI agents ([Agents](../../guides/agents/)).
- Tag and category archive pages for the `post` layout.
- Strict Content Security Policy support ([CSP](../../recipes/csp/)) and a [math and diagrams guide](../../recipes/math-diagrams/).
- Documentation in English, Korean and Japanese.

## Compatibility

- GitHub Pages (`github-pages` 232, Jekyll 3.10) with `remote_theme`, and Jekyll 4.4 on Ruby 3.2 to 3.4. Jekyll 3.9 is the oldest supported version.
- The public API is documented on [Public API](../api/); changes are listed in the CHANGELOG. See [Migrate and upgrade](../../guides/upgrade/).

## Next

- New components and options are added without breaking existing sites where possible.
