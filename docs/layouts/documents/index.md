---
nav_order: 70
title: Documents
description: Legal pages with dates, a version and a contents list, and a print-first resume, two layouts for pages that people keep or print.
---
# Documents

Two layouts for pages people print or keep. Both hide the site header, footer and banners on paper.

| Layout | Front matter | Bundle | Structured data | Demo |
|---|---|---|---|---|
| `legal` | `effective` (required), `updated`, `version`, `toc: false` | pages | WebPage with dates | [Legal](legal/) |
| `resume` | `display_name`, `headline`, `email`, `phone`, `location`, `links`, `experience`, `education`, `skills` | resume | ProfilePage + Person | [Resume](resume/) |

## Legal

```yaml
---
layout: legal
effective: 2026-01-01
updated: 2026-10-30
---
```

The contents list is built from the `##` and `###` headings in the body; `toc: false` hides it. The dates become `datePublished` and `dateModified`.

## Resume

```yaml
display_name: Ada Example
experience:
  - {role: Lead engineer, org: Example Docs, start: 2024-03-01}
education:
  - {degree: BSc, school: Example University, end: 2019-02-01}
skills:
  - {group: Languages, items: [Ruby, JavaScript]}
```

`display_name` is the heading and the Person's `name`; without it the title is used. Do not use `name:`: Jekyll replaces it with the page's file name, and `modootoday-check` warns about it.

An entry with no `end` shows "Present" and becomes the Person's `worksFor`. Schools become `alumniOf` and skills `knowsAbout`. The markup also carries h-card classes. The page is laid out for A4 and Letter paper first and reflows on screens.
