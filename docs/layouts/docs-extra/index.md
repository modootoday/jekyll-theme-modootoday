---
nav_order: 60
title: Docs extras
description: Reference, changelog, roadmap, glossary, hub, course and book pages with one shared optional stylesheet.
---
# Docs extras

These layouts cover the pages around a manual. They load `modootoday-docs-extra.css` only on their own pages and add no JavaScript. Each reads a title and a `description:` (the lead); the page body comes after the generated part unless noted.

| Layout | Front matter | Structured data | Demo |
|---|---|---|---|
| `reference` | `members: [{name, signature, text, since, id}]` | TechArticle | [Reference](reference/) |
| `changelog` | `releases: [{version, date, url, added, changed, fixed, removed, security}]` | WebPage | [Changelog](changelog/) |
| `roadmap` | `items: [{title, status, text, url}]`, status `now`, `next` or `later` | WebPage | [Roadmap](roadmap/) |
| `glossary` | `terms: [{term, text, id, url}]` | DefinedTermSet | [Glossary](glossary/) |
| `hub` | `cards: [{title, text, url}]` | CollectionPage | [Hub](hub/) |
| `course` | `level`, `modules: [{title, lessons: [{title, url, minutes}]}]` | Course | [Course](course/) |
| `book` | `image`, `author`, `isbn`, `pages`, `chapters: [{title, url}]` | Book | [Book](book/) |
| `reference` with `sidebar: true` and `packages:` | `group` on members; `packages: [{name, version, text, url, links: [{label, url}]}]`, `packages_title`, `packages_compact`, `packages_position` | TechArticle | [API reference](api/) |

## Changelog

Each release lists its changes under the five category headings, in that order, with labels in the page language. Items are Markdown. `modootoday-check` reports any other key, so a typo such as `fix:` does not vanish silently.

Feed: a changelog can also be an Atom feed, one entry per release, with no plugin. Add a second file, `changelog.xml`, that holds only front matter and names the changelog page in `feed_source:`; then `feed:` on the changelog page links the feed in the head and as a Subscribe link under the title. `releases_feed: true` adds GitHub's releases feed of the site's repository (from `site.github`) as a second link; give its URL instead where `site.github` is not available.

```yaml
# changelog.md
---
layout: changelog
title: Changelog
feed: /changelog.xml
releases_feed: true
releases:
  - {version: 1.1.0, date: 2026-11-01, added: ["Dark mode"], fixed: ["Search on phones"]}
---
```

```yaml
# changelog.xml
---
layout: feed
feed_source: /changelog/
feed_title: My project releases
---
```

Each entry links to the release's `url`, or else to the version's heading on `home:` (default the `feed_source` page). Entry ids are built from the site host, the release date and the version, so a feed reader never shows a release twice.

`feed_source: data` reads `_data/releases.yml` instead of a page. The theme does not write that file: you write it, by hand or with your own script, and set `home:` to the page that lists the releases. It is a list, newest first, with `version`, `date`, an optional `url`, and either `sections` (each a `name` and its `items`) or the changelog layout's five keys:

```yaml
# _data/releases.yml
- version: 1.1.0
  date: 2026-11-01
  url: https://github.com/OWNER/REPO/releases/tag/v1.1.0
  sections:
    - name: Added
      items: ["Dark mode"]
    - name: Fixed
      items: ["Search on phones"]
```

A `name` is shown as written; items are Markdown.

## Glossary

Terms are sorted for you and grouped by first letter, with a letter bar that links only to letters in use. Every term gets an anchor (`id:` or a slug of the term), and the page data lists each one as a DefinedTerm.

## Course

Lesson `minutes` add up to the total shown under the title and to `timeRequired`. The course provider is the site publisher; a `description:` is required.

## API sidebar and package table

Both are opt-in on the `reference` layout; a page without them renders as before. `sidebar: true` moves the member list into a side column that stays in view on wide screens (64rem and up). Members that share a `group:` are listed under that label, in the order the groups first appear; on narrow screens the same list sits above the page. `packages:` adds a table with one row per package (name, version and links, with the `text` under the name), before the body; on small screens each row stacks into a short card. A reference page with `packages:` may leave out `members:`. Both use CSS only.

When the body already describes each package, `packages_compact: true` leaves out the `text` under each name, and `packages_position: after` moves the table below the body (the default is `before`). A Markdown page sets the table in front matter only: `modootoday-check` rejects Liquid in page bodies, because GitHub shows it as plain text. In your own layouts or HTML pages, include `modootoday/docs-extra/packages.html` (with `items=page.packages`, and optionally `caption=` and `compact=true`) wherever the table should go. The body of a reference page turns GitHub alerts (`> [!TIP]` and the rest) into callouts, as the `doc` layout does. The page's Markdown twin and `llms-full.txt` carry the package table as a Markdown table, in the same place.

## Checks

`modootoday-check` requires the list each layout is built on, a valid `status`, a `text` for each term, no duplicate terms, a `url` for each hub card, whole-number `minutes` and `pages`, and a 10- or 13-digit `isbn`.
