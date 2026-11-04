---
id: sot:modootoday/docs-demo-to-starter-map
title: Docs demo to starter map
status: active
created: 2026-11-04T17:11:42Z
updated: 2026-11-04T17:15:17Z
verify: [manual]
rel:
  governs: [docs/layouts, example/starters.yml]
  implements: [adr:modootoday/20261104171141]
  evidence: [research:modootoday/20261104170510]
---

# Docs demo to starter map

Where each demo page of the docs site goes when its starter is published, what the docs keep at the old URL, and which starter shows each theme layout and feature. The decision and the migration rules are in [[adr:modootoday/20261104171141]]; this map is the list it acts on.

## Rule

### 1. How to read the map

- **Source.** The English source under `docs/`. The Korean and Japanese siblings (`.ko.md`, `.ja.md`) follow the same row; rows marked "en" have no translations.
- **Starter and page.**
  - The starter is a `name` from `example/starters.yml`.
  - The page is a path inside that starter's demo, `https://modootoday.github.io/jekyll-theme-modootoday-<name>-starter/<page>`.
  - The page is the target; its URL inside the starter is stable once published.
- **Wave.** The publish in which the row moves (section 4). A row moves once, to its final starter.
- **Docs keep.** What stays at the old URL after the move:
  - **ref:** the URL becomes the layout's reference page: description, front matter keys, a small static preview image, and a "Live demo" link (new tab).
  - **stub:** the URL becomes a redirect stub to the starter page ([[adr:modootoday/20261104171141]], "Redirects").
  - **stays:** the page is not a demo and remains as it is.

### 2. Layout demos

| Source (docs/) | Layout | Starter | Page in the starter | Wave | Docs keep |
|---|---|---|---|---|---|
| `layouts/directory/portfolio.md` | portfolio | portfolio | `/work/` | 4 | ref |
| `layouts/directory/team.md` | team | company | `/team/` | 5 | ref |
| `layouts/directory/jobs.md` | jobs | company | `/careers/` | 5 | ref |
| `layouts/directory/events.md` | events | conference | `/schedule/` | 6 | ref |
| `layouts/directory/sponsors.md` | sponsors | oss | `/sponsors/` | 5 | ref |
| `layouts/directory/integrations.md` | integrations | docs | `/plugins/` | 1 | ref |
| `layouts/detail/project.md` | project | portfolio | `/work/<project>/` | 4 | ref |
| `layouts/detail/case-study.md` | case-study | saas | `/customers/<case>/` | 3 | ref |
| `layouts/detail/job.md` | job | company | `/careers/<job>/` | 5 | ref |
| `layouts/detail/event.md` | event | conference | `/sessions/<id>/` | 6 | ref |
| `layouts/detail/episode.md` | episode | podcast | `/episodes/<n>/` | 6 | ref |
| `layouts/marketing/feature.md` | feature | saas | `/features/<name>/` | 3 | ref |
| `layouts/marketing/pricing.md` | pricing | landing | `/pricing/` | 1 | ref |
| `layouts/marketing/download.md` | download | landing | `/download/` | 2 | ref |
| `layouts/marketing/brand.md` | brand | saas | `/brand/` | 3 | ref |
| `layouts/marketing/links.md` | links | portfolio | `/links/` | 4 | ref |
| `layouts/marketing/contact.md` | contact | saas | `/contact/` | 3 | ref |
| `layouts/blog-news/blog.md` | blog | blog | `/` | 1 | ref |
| `layouts/blog-news/post.md` | post | blog | a post page | 1 | ref |
| `layouts/blog-news/news.md` | news | newsroom | `/` | 5 | ref |
| `layouts/blog-news/article.md` | news-article | newsroom | an article page | 5 | ref |
| `layouts/blog-news/archive.md` | archive | blog | `/archive/` | 2 | ref |
| `layouts/docs-extra/reference.md` | reference | docs | `/reference/` | 2 | ref |
| `layouts/docs-extra/changelog.md` | changelog | saas | `/changelog/` | 3 | ref |
| `layouts/docs-extra/roadmap.md` | roadmap | saas | `/roadmap/` | 3 | ref |
| `layouts/docs-extra/glossary.md` | glossary | help-center | `/glossary/` | 3 | ref |
| `layouts/docs-extra/hub.md` | hub | help-center | `/` | 3 | ref |
| `layouts/docs-extra/course.md` | course | course | `/course/` | 5 | ref |
| `layouts/docs-extra/book.md` | book | course | `/handbook/` | 5 | ref |
| `layouts/docs-extra/api.md` | reference (API page) | docs | `/api/` | 2 | ref |
| `layouts/documents/legal.md` | legal | landing | `/privacy/` | 1 | ref |
| `layouts/documents/resume.md` | resume | portfolio | `/resume/` | 4 | ref |

The six group index pages (`layouts/<group>/index.md`) and `layouts/shells.md` are reference pages: they stay.

### 3. Shell, feature and record demos

| Source (docs/) | Shows | Starter | Page in the starter | Wave | Docs keep |
|---|---|---|---|---|---|
| `layouts/demo/index.md` | list of the demos below | – | – | 2 | stub to `/layouts/shells/` |
| `layouts/demo/home.md` | home | landing | `/` | 1 | stub |
| `layouts/demo/minimal.md` | minimal | landing | `/thanks/` | 2 | stub |
| `layouts/demo/wide.md` | wide | saas | `/` | 3 | stub |
| `layouts/demo/error.md` | error | docs | `/404.html` | 2 | stub |
| `layouts/demo/error-rtl.md` (en) | error, Arabic, right to left | help-center | `/ar/404.html` | 3 | stub |
| `layouts/demo/redirect.md` | redirect | docs | an alias URL of a moved guide page | 2 | stub |
| `layouts/demo/search.md` | search | docs | `/search/` | 2 | stub |
| `layouts/demo/orbit.md` | hero script visual with poster | landing | `/` (product-scene layer) | 2 | stub |
| `layouts/demo/filter.md` | list and table filter | marketplace | `/plugins/` (facets) | 4 | stub |
| `layouts/demo/csp.md` | every core component under a strict CSP | docs | the whole site (`csp: strict`) | 2 | stub to its home |
| `layouts/demo/code-github.md` | `code_theme: github` | docs | `/guide/` | 2 | stub |
| `recipes/records/index.md` (en) | records list | docs | `/plugins/` | 1 | stub |
| `recipes/records/<key>.md` (en, 5) | record pages | docs | `/plugins/<key>/` | 1 | stub |

### 4. Waves

| Wave | Starters published or republished | Theme prerequisite | Rows that move |
|---|---|---|---|
| 1 | docs, blog, landing, as they are today | the showcase (1.6.0) | 5 layout rows and 3 shell or record rows |
| 2 | docs, blog, landing, reworked on the presets | registry, config and the `base`, `editorial` and `product` presets | 4 layout rows and 8 shell or feature rows |
| 3 | saas, help-center | the product features and sibling-language mode | 8 layout rows and 2 shell rows |
| 4 | portfolio, marketplace | the `studio` preset; the marketplace data shape | 4 layout rows and 1 feature row |
| 5 | company, oss, course, newsroom | the `terminal` preset | 8 layout rows |
| 6 | conference, podcast | the `stage` preset, schedule and audio | 3 layout rows |

Total: 32 layout rows and 14 shell, feature and record rows. The record row covers the records index and its five record pages.

### 5. What is not a demo and stays in the docs

| Source (docs/) | Why it stays |
|---|---|
| `components/kitchen-sink.md` (en/ko/ja) | Component reference and the coverage gate (`test/system/docs/coverage.rb`). The docs rebuild replaces it with component group pages |
| `components/kitchen-sink-rtl.md` (en) | The right-to-left mirroring fixture for every component; a starter shows one RTL language, not every component |
| `index.md`, `home/index.<lang>.md` | The docs home in each language |
| `blog/`, `news/`, `authors/`, `_posts/` | The docs site's own release posts and updates, shown through the blog and news layouts. Their descriptions stop calling them samples |
| `recipes/<group>/index.md`, other recipes and guides | How-to pages. They link to the starter that shows the recipe |

The site-owned files that only served demos (`_layouts/examples.html`, `_includes/sections/*-demo.html` and `orbit-stage.html`, `assets/css/brand-demo.scss`, `code-github.scss`, `orbit.css`, and the hero module setting in `docs/_config.yml`) are removed with the last row that uses them.

### 6. Every layout and feature has a starter

Starters per layout. "+" lists further starters that also show it.

| Layout | Starter |
|---|---|
| default, doc, error, twin, llms, llms-full | every starter |
| home | landing (its home keeps `layout: home`) + portfolio |
| minimal | landing |
| wide | saas + company |
| search | docs + blog, help-center, marketplace |
| redirect | docs |
| blog, post | blog + saas, company |
| archive | blog + conference, newsroom |
| author | blog + course, newsroom |
| feed | blog + newsroom |
| news, news-article | newsroom |
| directory | saas (customers) |
| portfolio | portfolio |
| team | company + marketplace, oss, conference, podcast |
| jobs, job | company |
| events, event | conference |
| sponsors | oss + conference, podcast |
| integrations | docs + saas, marketplace |
| detail | docs (records) + marketplace |
| project | portfolio + company |
| case-study | saas + portfolio, company |
| episode | podcast |
| feature | saas + company |
| pricing | landing + saas, conference |
| download | landing + oss |
| brand | saas + oss |
| links | portfolio + podcast |
| contact | saas + help-center, portfolio, company, conference |
| reference | docs |
| changelog, roadmap | saas + oss |
| glossary | help-center + course |
| hub | help-center |
| course, book | course |
| legal | landing + saas, marketplace, company, oss, conference |
| resume | portfolio |

Features with a demo page or a docs-only fixture today:

| Feature | Starter |
|---|---|
| hero script visual and poster | landing (product-scene) + saas, portfolio, company, oss, conference, podcast |
| filter (text) | docs + help-center, marketplace |
| filter (facets) | marketplace + saas, company, conference |
| strict CSP | docs + help-center, marketplace |
| `code_theme: github` | docs + oss |
| records and byte-exact folders | docs + marketplace |
| directory-mode languages | docs |
| sibling-mode languages and source revisions | help-center |
| right to left | help-center (partial Arabic) |
| URL aliases | docs |
| the showcase bar and pill | every published demo |

Gaps: none among layouts. Kept out of starters on purpose, each shown elsewhere:

- `css_layers` and `twins: source`: test fixtures in the theme's test suite;
- charts: until the chart feature lands;
- the RTL kitchen sink: in the docs.

## Why

- A layout looks right only in its own chrome, and a starter is what a user copies. Demonstrating a layout inside the starter that uses it shows the real result and keeps one copy of each sample.
- Keeping a reference page at a layout demo's URL keeps inbound links meaningful: they land on the page about that layout, one click from its live demo.
  - Shell, feature and record demos have no reference page of their own (shells share `layouts/shells`; features are documented on their feature page), so their URLs become stubs to the demo.
- Moving each row once, to its final starter, means no URL and no redirect changes twice. That is why the news rows wait for the newsroom starter instead of moving into today's blog starter.
- Waves follow the starter order of the catalog (the existing three, then saas and help-center, portfolio and marketplace, the rest), because each starter needs the theme features listed for its wave.

## Verification

- A test reads this map's tables and fails when:
  - a source path names no file while its wave is unpublished;
  - a moved row's source is anything other than a reference page or a stub;
  - a starter name is not in `example/starters.yml`;
  - a published starter's build lacks the row's page.
- A test fails when a layout in `_layouts/` has no row in section 6.
- `spec check` keeps this document's relations valid.
