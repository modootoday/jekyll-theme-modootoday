---
nav_order: 80
title: Structured data
description: The schema.org JSON-LD graph the theme prints on every page, and how to configure it.
---
# Structured data

When `url:` is set in `_config.yml`, every page gets one `<script type="application/ld+json">` block holding a schema.org `@graph`. Search engines and AI tools read it to learn what the page is. Without `url:` nothing is printed, because schema.org URLs must be absolute.

## What the graph contains

| Node | `@id` | Contents |
|---|---|---|
| `WebSite` | `<url>/#website` | site name, URL, language, publisher; a `SearchAction` when `schema.search_url` is set |
| `Organization` or `Person` | `<url>/#publisher` | `schema.publisher` (name, URL, logo, `same_as`) |
| page type (`WebPage` and subtypes) | `<page>#webpage` | name, URL, description, `inLanguage`, image, breadcrumb |
| main entity | `<page>#main` | the article, job, event or other thing the page is about |
| `BreadcrumbList` | `<page>#breadcrumb` | the same trail as the visible breadcrumb |

Dates are ISO 8601 with the site time zone; text is escaped so the block is safe under a strict [CSP](../../recipes/csp/).

## Type per layout

| Layout | Type |
|---|---|
| `post` | `BlogPosting` (`NewsArticle` with `layout: news-article` or `kind: news`) |
| `doc` | `TechArticle` |
| `archive`, `blog`, `news` | `CollectionPage` |
| `author`, `profile`, `resume` | `ProfilePage` |
| `contact` | `ContactPage` |
| `search` | `SearchResultsPage` |
| `faq` | `FAQPage` |
| others | `WebPage` |

Authors come from `author`/`authors` in front matter, looked up in `_data/authors.yml`.

## Configuration

```yaml
modootoday:
  schema:
    publisher:
      type: Organization        # or Person
      name: Example Inc.
      url: https://example.com/
      logo: /assets/logo.png
      same_as: [https://github.com/example]
    search_url: /search/?q={search_term_string}   # optional SearchAction
    layouts:
      landing: SoftwareApplication               # override the type for a layout
```

Turn it off with `modootoday.schema: false` (or `schema: {enabled: false}`), or for one page with `schema: false` in front matter. `seo: false` also removes it.

## Per-page entities

Set `schema.type` and any schema.org properties in front matter; `type:` keys become `@type`. The theme fills `name`, `description`, `url` and `image` from the page.

```yaml
schema:
  type: JobPosting
  datePosted: 2026-10-01
  hiringOrganization: {type: Organization, name: Example Inc.}
  jobLocation: {type: Place, address: {type: PostalAddress, addressCountry: KR}}
```

Other supported types include `SoftwareApplication` with `offers: {type: Offer, price: 0, priceCurrency: USD}`, `Event`, `Course`, `PodcastEpisode`, `DefinedTermSet`, `ItemList` and `FAQPage` (`mainEntity:` list of `Question`). Top-level URLs starting with `/` are made absolute; URLs inside nested values must already be absolute.

## Checking

`modootoday-check` validates every block in the built site offline: one block per page, valid JSON, known schema.org types and properties, required properties (Google's list), unique `@id`s, absolute URLs, ISO 8601 dates, and agreement with `og:url`, `og:title`, `og:image` and `<html lang>`. Add `--schema-recommended` to also list missing recommended properties.
