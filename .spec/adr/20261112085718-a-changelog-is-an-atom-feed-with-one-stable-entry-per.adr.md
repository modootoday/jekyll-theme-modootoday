---
id: adr:modootoday/20261112085718
title: "A changelog is an Atom feed with one stable entry per release, and GitHub's releases feed is a plain alternate"
status: active
created: 2026-11-12T08:57:18Z
updated: 2026-11-12T09:43:03Z
rel:
  governs: [_includes/modootoday/docs-extra/feed-entries.html, _layouts/feed.html, _includes/modootoday/meta/releases-feed.html, lib/modootoday/check/build/feeds.rb]
  depends_on: [adr:modootoday/20261109141321, adr:modootoday/20261112001116, adr:modootoday/20261112023954, adr:modootoday/20261109204422]
---

# A changelog is an Atom feed with one stable entry per release, and GitHub's releases feed is a plain alternate

## Context

F7 and R4 in [[adr:modootoday/20261109141321]]: readers who follow releases had only GitHub's own feed, and a site's changelog page could not be followed at all. Release data comes in two shapes: the `layout: changelog` page's `releases:` with Keep a Changelog keys, and the generated `_data/releases.yml` with `sections: [{name, items}]` ([[adr:modootoday/20261109204422]]).

## Decision

- `layout: feed` takes `feed_source:`: `data` reads `site.data.releases`, a page URL reads that page's `releases:` through the cached page lookup (no pass over `site.pages`). `docs-extra/feed-entries.html` normalises both shapes into one entry per release, newest first: the version as the title, `tag:<host>,<release date>:<baseurl>/<version>` as the id, so an entry never changes identity, the release date as `updated`, the release URL as the link or else the page's `#v…` anchor (`home:`, default the source page), and the items as an escaped HTML list. Generated data carries only each change's lead, which is what the entry shows.
- Front matter `releases_feed: true` links GitHub's `releases.atom` for the site's repository (the repository from `meta/github.html`, no API call), or the URL given, as a head alternate titled "GitHub releases" and, on docs-extra pages (changelog, download), as a link under the title next to the page's own Subscribe link. New label `layouts.releases_feed` in all 23 catalogs.
- `modootoday-check` requires a `feed_source:` to be `data` or a page in the build, and parses every built Atom feed with REXML (standard library), failing on one that is not well-formed.
- The docs site publishes `/changelog.xml` from the generated data and a feed of the changelog demo; their pages name `releases_feed:` explicitly, because CI builds have no `site.github`.

## Consequences

- The reference changelog and the changelog demo, in en, ko and ja, gain the feed and releases links (an intended visual change).
- Tests: `test/theme/blog/changelog_feed_test.rb` (both shapes, ids, links, content, updated, the head and visible links) and `test/checker/build/feeds_test.rb`.
