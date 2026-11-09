---
title: Legal layout
description: "Terms, privacy and other policies with dates, a version and a contents list, laid out for print."
layout: layout-reference
nav_order: 1
twin: true
---
# Legal layout

`layout: legal` is for terms of use, privacy policies and other pages people keep or print. It shows the effective date, the date of the last update and a version above the text, builds a contents list from the `##` and `###` headings, and hides the site header, footer and banners on paper. The live demo is the privacy policy of the landing starter.

## Front matter

| Key | Use |
|---|---|
| `effective` | The date the text takes effect, `YYYY-MM-DD` (required) |
| `updated` | The date of the last change |
| `version` | A version label, such as `"3"` |
| `toc` | `false` hides the contents list |

```yaml
---
title: Privacy policy
layout: legal
effective: 2026-01-01
updated: 2026-10-30
version: "1"
---
```

The dates become `datePublished` and `dateModified` in the page's structured data. [Documents](../) also covers the resume layout.
