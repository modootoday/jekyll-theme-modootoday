---
id: adr:modootoday/20261104061806
title: "One author resolver feeds the byline, the Atom feed and JSON-LD"
status: active
created: 2026-11-04T06:18:06Z
updated: 2026-11-04T06:19:09Z
rel:
  governs: [_includes/modootoday/site/author.html, _includes/modootoday/meta/byline.html, _includes/modootoday/jsonld/author.html, _layouts/feed.html]
---

# One author resolver feeds the byline, the Atom feed and JSON-LD

## Context

The byline, the Atom feed and the JSON-LD `author` property each parsed `authors | default: author` on their own. They read `_data/authors.yml` keys and comma lists only. A map such as jekyll-seo-tag's `author: {name, url, picture}` was iterated as key-value pairs, and the site's `author:` (minima, jekyll-seo-tag) was never read, so a switched site lost its author everywhere.

## Decision

- `_includes/modootoday/site/author.html` sets `mt_authors` for `include.of` (default `page`). Sources in order: `authors`, `author`, `modootoday.schema.author`, `site.author`. A value is a map with `name` (used as is), a list, or a string split on commas; a list entry that is a map with `name` is kept, a string is looked up in `_data/authors.yml` and replaced by its entry when that has a `name`, else kept as the name.
- Liquid cannot build maps, so an entry is either a map (`name`, `url`, `page`, `avatar` or `picture`, `bio`, `email`) or a plain name. Consumers print `entry.name | default: entry`; a string has no `name` key, so the name falls through.
- The byline, the feed entries and `jsonld/author.html` call it and keep their markup. Output for ids and comma lists is unchanged.
- The `author` layout keeps reading its own profile by id, since it is one author's page, not a list.

## Consequences

Posts without an author now show the site's author in the byline, the feed and JSON-LD, as minima and jekyll-feed do. A site that set `modootoday.schema.author` only for JSON-LD now also sees it in bylines; `modootoday.authors: false` still hides bylines.
