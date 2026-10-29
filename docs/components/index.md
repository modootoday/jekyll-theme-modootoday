---
title: Components
description: Every component and the Markdown that produces it.
sections:
  - {c: features, name: catalog, cols: 2}
  - status
  - {c: cta, name: next}
---
# Components

Each component is ordinary Markdown. On github.com it falls back to the plain element.

[Open the kitchen sink](kitchen-sink/)

## Catalog

- **Alerts** — `> [!NOTE]` and four more types become callouts. `status:available`
- **Sections** — `sections:` front matter maps `##` headings to layouts. `status:available`
- **Cards** — A list of `- **Title** — text` items becomes a grid. `status:available`
- **Buttons** — A link-only paragraph becomes call-to-action buttons. `status:available`
- **Tabs** — `###` + code block pairs become accessible tabs. `status:available`
- **Status badges** — Status code spans become badges. `status:available`
- **Tables** — GFM tables scroll horizontally on small screens. `status:available`
- **Accordion and steps** — `c: accordion` and `c: steps` sections. `status:available` `since:0.3`
- **Figure** — An image followed by an emphasis-only paragraph. `status:available` `since:0.3`
- **Breadcrumb, TOC, theme toggle** — Added automatically by the layout. `status:available` `since:0.3`
- **Tag and since badges** — Tag and since code spans. `status:available` `since:0.3`
- **Timeline** — `c: timeline` sections. `status:available` `since:0.4`
- **Keyboard keys** — `kbd:Ctrl+K` code spans. `status:available` `since:0.4`
- **Search** — Client search from a `search.json` file. `status:available` `since:0.4`
- **Component slots** — `_data/components.yml` slot contract. `status:planned`

## Status legend

| Badge | Meaning |
|---|---|
| `status:available` | shipped and stable |
| `status:partial` | works with known limits |
| `status:planned` | on the roadmap |

## Next

[Kitchen sink](kitchen-sink/) [Configuration](../configuration/)
