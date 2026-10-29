---
nav_order: 20
title: First page
description: Write a page with front matter, sections and alerts.
sections:
  - front-matter
  - body
  - rules
  - {c: cta, name: next}
---
# Write your first page

A page is a Markdown file with a small front matter block. The theme does the rest.

## Front matter

```yaml
---
title: Getting started
description: shown in search results and llms.txt
sections:
  - {c: features, name: highlights}
  - {c: cta, name: next}
---
```

Each `sections:` item maps to one top-level `##` heading, in order. Leave `sections:` out for a plain article.

## Body

```markdown
# Getting started

One sentence that explains the page.

## Highlights

- **Fast** — Builds in under a second.
- **Plain** — Readable on GitHub.

## Next

[Install](../install/)
```

> [!NOTE]
> The text before the first `##` becomes the hero. A paragraph that contains only links becomes buttons.

## The rules in one minute

| Allowed | Not allowed |
|---|---|
| GFM tables, lists, task lists | raw HTML and HTML comments |
| fenced code with one language word | Liquid tags in page bodies |
| top-level GitHub alerts | kramdown attributes and `{#id}` |
| `<https://…>` autolinks | bare URLs |

The full list lives in [RULES.md](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/RULES.md).

## Next

[Explore components](../../components/) [Back to install](../install/)
