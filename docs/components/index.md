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
- **Cards** — a list of `- **Title** — text` items becomes a grid. `status:available`
- **Buttons** — a link-only paragraph becomes call-to-action buttons. `status:available`
- **Tabs** — `###` + code block pairs become accessible tabs. `status:available`
- **Status badges** — status code spans become badges. `status:available`
- **Tables** — GFM tables scroll horizontally on small screens. `status:available`
- **Accordion, steps, TOC** — on the roadmap for v0.3. `status:planned`

## Status legend

| Badge | Meaning |
|---|---|
| `status:available` | shipped and stable |
| `status:partial` | works with known limits |
| `status:planned` | on the roadmap |

## Next

[Kitchen sink](kitchen-sink/) [Configuration](../configuration/)
