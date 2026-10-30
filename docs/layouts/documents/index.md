---
title: Documents
description: Legal pages and a print-first resume.
nav_order: 60
---
# Documents

Two layouts for pages people print or keep. Both hide the site header, footer and banners on paper.

| Layout | Front matter | Bundle | Structured data | Demo |
|---|---|---|---|---|
| `legal` | `effective` (required), `updated`, `version`, `toc: false` | pages | WebPage with dates | [Terms](/jekyll-theme-modootoday/layouts/documents/legal/) |
| `resume` | `name`, `headline`, `email`, `phone`, `location`, `links`, `experience`, `education`, `skills` | resume | ProfilePage + Person | [Resume](/jekyll-theme-modootoday/layouts/documents/resume/) |

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
experience:
  - {role: Lead engineer, org: Example Docs, start: 2024-03-01}
education:
  - {degree: BSc, school: Example University, end: 2019-02-01}
skills:
  - {group: Languages, items: [Ruby, JavaScript]}
```

An entry with no `end` shows "Present" and becomes the Person's `worksFor`. Schools become `alumniOf` and skills `knowsAbout`. The markup also carries h-card classes. The page is laid out for A4 and Letter paper first and reflows on screens.
