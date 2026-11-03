---
title: Filter demo
description: "A list and a table that readers narrow by typing, with a button per value on the table: the filter: section parameter."
twin: false
sitemap: false
edit: false
nav_exclude: true
sections: [{name: tools, filter: true}, {name: plans, filter: {facet: 3}}, setup]
---
# Filter demo

Type in the field above the list or the table: only the items that contain every word you type stay. Case, accents written two ways and Korean spacing do not matter. Without JavaScript every item stays visible.

[Search recipe](../../../recipes/search/)

## Tools

- **Keyword volume**: monthly searches for a keyword
- **검색량 조회**: Korean for volume lookup; typing it without the space finds it too
- **Rank tracker**: where a page ranks over time
- **Trend chart**: interest over the past year
- **Related terms**: words people search together

## Plans

| Plan | Price | Kind |
|---|---|---|
| Starter | 0 | Free |
| Team | 9 | Paid |
| Archive | 0 | Free |
| Business | 29 | Paid |

## Setup

```yaml
# front matter
sections:
  - {name: tools, filter: true}
  - {name: plans, filter: {facet: 3}}
  - setup
```

`filter: true` filters the first list or table of that section. `{facet: 3}` also adds a button for each value in the third column; press one to show only its rows, press it again to show all. On a page without `sections:`, set `filter:` in the front matter instead. Only pages with a filter load `filter.js` and its sheet.
