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
| any page with a `c: faq` section and `schema.faq: auto` | `FAQPage` |
| `glossary` | `DefinedTermSet`; a page with `schema: {type: DefinedTerm}` is one `DefinedTerm` |
| `course` | `Course`; `LearningResource` through `schema.type` or `schema.layouts` |
| others | `WebPage` |

Authors come from `author`/`authors` in front matter (ids looked up in `_data/authors.yml`, names, or a `{name, url}` map), else from `modootoday.schema.author`, else from the site's `author:`; the byline and the Atom feed show the same people.

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
    faq: auto                                    # FAQPage from c: faq sections (default off)
    layouts:
      landing: SoftwareApplication               # override the type for a layout
```

Turn it off with `modootoday.schema: false` (or `schema: {enabled: false}`), or for one page with `schema: false` in front matter. `seo: false` also removes it.

With `seo: false` and `jekyll-seo-tag`, the plugin writes its own JSON-LD between the `<!-- Begin Jekyll SEO tag` and `<!-- End Jekyll SEO tag -->` comments. `modootoday-check` checks that block only for valid JSON and reports a warning, not errors: the kit does not write it, and its `WebPage` has `headline` but no `name`. schema.org marks no property as required, and Google lists no required properties for `WebPage`; the required-property list is the kit's own rule for the markup it writes. To have the page checked in full, move to the kit's tags ([Migrate](../upgrade/#from-jekyll-seo-tag)).

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

## FAQ, terms and learning resources

**FAQPage from the page.** Set `faq: auto` under `modootoday.schema` for every page, or `schema: {faq: auto}` in one page's front matter. A page with a `c: faq` section then becomes an `FAQPage`: each `###` question of that section is a `Question`, and the text under it is the `Answer`. The visible text is the only source, so the structured data always matches what readers see; code blocks are left out of the answer, and `c: details` sections are not read. `schema.type` and `schema.mainEntity` in front matter still win, and `schema: {faq: false}` turns it off for one page. The [Components](../../components/) page uses it.

**A page per term.** `schema: {type: DefinedTerm}` makes the page a `DefinedTerm` named by its title. `term_set:` with the glossary page's path links it to that page's `DefinedTermSet` (an absolute URL is printed as it is), and `term_code:` adds `termCode`. On the glossary, `url:` on an entry of `terms:` adds the term page's URL to that `DefinedTerm`.

```yaml
title: Token
description: A named value for one design decision.
schema: {type: DefinedTerm}
term_set: /glossary/
```

**LearningResource.** Set it for one page with `schema: {type: LearningResource}`, or for a layout with `schema.layouts: {doc: LearningResource}`. It reads the same front matter as the course layout: `level` (`educationalLevel`), `minutes` (`timeRequired`), `teaches` and `resource_type` (`learningResourceType`), with the site publisher as `provider`.

## Checking

`modootoday-check` validates every block in the built site offline: one block per page, valid JSON, known schema.org types and properties, required properties (Google's list), unique `@id`s, absolute URLs, ISO 8601 dates, and agreement with `og:url`, `og:title`, `og:image` and `<html lang>`. An `FAQPage` without questions, a question with an empty answer, and a `DefinedTerm` whose `term_set` is not a built page holding a `DefinedTermSet` are errors, and so is a `modootoday.schema.faq` other than `auto` or `false`. Add `--schema-recommended` to also list missing recommended properties.

A single object under a property, such as `offers`, `organizer` or `acceptedAnswer`, is checked with the rules of its `@type` like a top-level node. What it breaks (a missing required property, an unknown type or property, a relative URL, a date that is not ISO 8601) is reported as a warning ending in "(a warning in a nested object, an error in the next major version)"; the next major version makes it an error. A nested object without `@type` is not asked for one, and a question with an empty answer stays an error. For example, an event's `offers` with a `url` but no `price` and `priceCurrency` is a warning, which names the fix: give the offer in front matter, `schema: {offers: {type: Offer, price: 0, priceCurrency: KRW, url: ...}}`, as the [event example](../../layouts/detail/#event) does (`tickets:` alone gives only its `url`). Show the price on the page too, so the markup states nothing the reader cannot see.
