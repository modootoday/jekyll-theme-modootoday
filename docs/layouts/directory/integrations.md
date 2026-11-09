---
title: Integrations layout
description: "Cards for integrations or plugins, with a logo, a category and a filter by category."
layout: layout-reference
nav_order: 6
twin: true
---
# Integrations layout

`layout: integrations` lists integrations, plugins or extensions as cards: a logo, the name, a category and one line of text. The cards come from `items:`, from a file in `_data`, or from a record set, in which case every card links to its own record page. When the cards have two or more categories, a row of buttons filters them without JavaScript. The live demo is the docs starter's plugin list, built from five records.

## Front matter

| Key | Use |
|---|---|
| `items` | The cards: `name` or `title`, `category`, `text`, `url`, `image`, `alt`, `width`, `height` |
| `data` | The name of a `_data` file to read the cards from instead of `items` |
| `records` | A record set from `modootoday.records`; each card links to its record page |
| `filter` | `false` hides the category buttons; another field name filters by that field |
| `filter_text` | `true` adds a search field that narrows the cards as you type |

The page prints an `ItemList` in its structured data. [Directory layouts](../) explains items, filters and record sets for every directory layout, and [Generated pages](../../../recipes/generated-pages/) shows how to give each record its own page.
