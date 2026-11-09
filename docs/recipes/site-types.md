---
moved_from: [recipes/marketing/index.md, recipes/company/index.md, recipes/docs/index.md, recipes/personal/index.md, recipes/community/index.md, recipes/system/index.md]
nav_order: 30
title: Site types
description: Which layouts make a product, company, documentation, personal or community site, and the system pages every site needs.
---
# Site types

Each section names the layouts one kind of site is built from and how they fit together. The layout group it links documents every front matter key and has a live demo of each layout.

## Product site

Make `/` a `feature` page whose `actions:` link to `/pricing/` and `/download/`. Keep one `pricing` page with every plan, set `version` and `date` on `download` from your release, and link a `brand` page from the footer. All four share `modootoday-marketing.css`, so a visitor loads it once.

Layouts: `feature`, `pricing`, `download`, `brand`, in [Marketing pages](../../layouts/marketing/).

## Company pages

Use `team` for people, `jobs` with one `job` page per opening, `contact` for ways to reach you, and `legal` for terms and privacy with an `effective` date. Set the site `publisher` once; every page then names the same Organization in its structured data.

Layouts: `team` and `jobs` in [Directory layouts](../../layouts/directory/), `job` in [Detail pages](../../layouts/detail/), `contact` in [Marketing pages](../../layouts/marketing/), `legal` in [Documents](../../layouts/documents/).

## Documentation site

Make the docs home a `hub` with one card per section. Generate `reference` members from your CLI or API, append each release to the `changelog`, and keep shared words in one `glossary` so guides can link to `/glossary/#term`. These pages load `modootoday-docs-extra.css`; guide pages stay on the core sheet.

Layouts: `hub`, `reference`, `changelog`, `glossary`, in [Docs extras](../../layouts/docs-extra/).

## Personal site

Put a `links` page at `/`, a `resume` at `/cv/` and `portfolio` with `project` pages for your work. Use the same `display_name` on the link page and the resume so both ProfilePages describe one Person; print the resume from the browser to get a clean PDF.

Layouts: `links` in [Marketing pages](../../layouts/marketing/), `resume` in [Documents](../../layouts/documents/), `portfolio` in [Directory layouts](../../layouts/directory/), `project` in [Detail pages](../../layouts/detail/).

## Community site

List meetups with `events` and one `event` page each, share plans on a `roadmap` with `now`, `next` and `later`, and thank backers on `sponsors`. Link the roadmap items to issues so readers can follow the work.

Layouts: `events` and `sponsors` in [Directory layouts](../../layouts/directory/), `event` in [Detail pages](../../layouts/detail/), `roadmap` in [Docs extras](../../layouts/docs-extra/).

## System pages

Add `404.md` with `layout: error`, use `redirect` for pages that moved, and give search its own page with `layout: search`. These pages use the small `pages` optional stylesheet; set `sitemap: false` on error pages so they stay out of the sitemap. Error pages have no Markdown twin and stay out of `llms.txt`, so `modootoday-check --twins` passes without a stub for them.

Layouts: `error`, `redirect`, `search`, in [Page shells](../../layouts/shells/).
