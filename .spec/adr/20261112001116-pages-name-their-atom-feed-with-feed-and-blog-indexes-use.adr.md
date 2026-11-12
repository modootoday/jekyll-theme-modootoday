---
id: adr:modootoday/20261112001116
title: "Pages name their Atom feed with feed: and blog indexes use the language feed, with no scan of site pages"
status: active
created: 2026-11-12T00:11:16Z
updated: 2026-11-12T00:11:35Z
rel:
  governs: [_includes/modootoday/meta/feed-url.html, _includes/modootoday/meta/feeds.html, _includes/modootoday/blog/subscribe.html, lib/modootoday/check/build/feeds.rb]
  depends_on: [adr:modootoday/20261109141321]
---

# Pages name their Atom feed with feed: and blog indexes use the language feed, with no scan of site pages

## Context

F6 in [[adr:modootoday/20261109141321]]: the head linked only the site's language feed (`modootoday.feed: true`), so a reader on a blog, author or tag page saw no feed to subscribe to, and an author had no feed of their own. Finding "the feed for this page" by walking `site.pages` costs a `to_liquid` per page on every render, which the theme avoids everywhere (`lookup/urls.html`).

## Decision

- A page names its feed with front matter `feed:`: a site path to a `layout: feed` page, or `false`. Without it, a blog index with no `category` or `tag` uses the language feed when `modootoday.feed` is `true`. No other convention and no scan: `meta/feed-url.html` checks only that the named page exists, through the one cached URL list.
- The head links the site feed as before and the page's own feed when it differs, titled "site – page". Blog, author and archive pages show a Subscribe (Atom) link with the RSS icon; it reuses existing markup and adds no CSS (0 B). The label is `blog.subscribe`, in all 23 catalogs.
- `layout: feed` takes `author:` (the post selector already filtered by author), so an author feed is one page.
- `modootoday-check` reports a `feed:` that is neither `false` nor a site path to an `.xml` page in the build, because the theme drops a feed it cannot find and the link would vanish silently.
- Per-tag and per-category feed stubs (`modootoday-stubs --feeds`) are deferred to 1.8: the decision of 2026-11-11 keeps 1.7.0 to explicit `feed:`.

## Consequences

- The head's site-feed block moves from `head-meta.html` to `meta/feeds.html`; its output is unchanged.
- The docs blog indexes and author pages gain `feed:`, and the docs site gains `/authors/modootoday.xml`; their pages show the Subscribe link (an intended visual change).
- Tests: `test/theme/feeds_test.rb` (language feed once, filtered and `feed: false` pages without a link, author feed and a missing one dropped, archive link, author-filtered feed) and `test/checker/build/feeds_test.rb`.
