---
id: adr:modootoday/20261114115001
title: "Docs links name the Markdown file, so they open on GitHub and jekyll-relative-links turns them into URLs on both builders"
status: active
created: 2026-11-14T11:50:01Z
updated: 2026-11-14T12:11:18Z
rel:
  governs: [docs]
  depends_on: [adr:modootoday/20261103071902]
---

# Docs links name the Markdown file, so they open on GitHub and jekyll-relative-links turns them into URLs on both builders

## Context

The docs pages wrote their relative links as site URLs (`../upgrade/#upgrading`, `../../layouts/blog-news/`), as [[adr:modootoday/20261103071902]] asked. They work on the site, but on github.com a link resolves from the file's place, and most of them name a folder that does not exist there: 649 of the 1,274 relative links in 131 files broke when the Markdown was read on GitHub. The project promises pages that read well on GitHub.

That ADR chose URLs because the classic builder's jekyll-relative-links matches a link against each file's real path, and a translation's real path (`install.ko.md` beside `install.md`) no longer mirrors its URL (`/ko/guides/install/`). That only misleads a link that reaches a file through a folder that mirrors a URL. A link that names the target file (`upgrade.ko.md`) is matched exactly, and the plugin writes that file's URL, permalink included.

A spike measured jekyll-relative-links 0.6.1 on the classic stack (github-pages 232, Jekyll 3.10) and on Jekyll 4.4 with the same plugin: links from an English page, a `.ko.md` translation beside it, a page in a subfolder and a `_posts` file, to pages, posts, feeds and images, with and without fragments, inline and as reference definitions, all became the same URLs on both. Two limits showed:

- A post's links are converted only with `relative_links: {collections: true}`.
- An inline link with a title on the same line (`[Open](news.md "new-window")`) is left as it is, because the plugin reads the title as part of the path. A reference definition with the title on the next line is converted and keeps the title, on both builders and on GitHub.

The plugin also rewrites links inside fenced code. It already did that on the classic builder, so it is not a change there.

## Decision

- Every relative link in docs Markdown names a file, relative to the page's file: `upgrade.md#upgrading`, `../layouts/blog-news/index.ko.md`, `../../feed.ko.xml`, `../assets/images/x.webp`. A translation links the file of its own language where one exists.
- A link with a `"new-window"` title is a reference definition with the title on the next line.
- `docs/_config.yml` names `jekyll-relative-links` in `plugins` and sets `relative_links: {collections: true}`. `gemfiles/jekyll4.gemfile` adds `jekyll-relative-links` 0.6.1 and `jekyll-sitemap` 1.4.0, the github-pages 232 versions, outside the `jekyll_plugins` group, so only a site that names them (the docs site) loads them and the docs site builds on that stack.
- `script/docs-index` writes the section index lists and the Markdown rules page with file links.
- The docs rule "R8 relative links name a file" (`test/system/docs/rules/links.rb`) blocks: a relative link in any docs Markdown file (pages, translations, sample posts; not `generated/`, not error pages) must name a file inside `docs/`, must not be root-absolute, and must not carry a title on its line. An error page keeps root-absolute links, as before.
- Fragments stay as they are. GitHub's heading slugs and the kramdown GFM ids agree on every fragment the docs link to (217, Korean and Japanese headings included). They differ only for headings that contain a link, such as the Changelog's release headings, which no page links to.

## Consequences

- 1,311 links in 217 files changed: 1,300 in place, 9 titled links on the Blog and news pages became reference definitions, and 2 links in the Korean and Japanese sample blog pages now reach the Blog and news page of their own language instead of the English one. 8 links already named the right file. The three root-absolute links of the 404 page stay.
- The built HTML of both stacks reaches the same targets as before, except those 2 links. On the site the plugin writes root-relative URLs with the base URL (`/jekyll-theme-modootoday/guides/upgrade/`) where the source had a relative URL; the targets are the same.
- The Markdown twins and `llms-full.txt` copy the source byte for byte, so their links now name source files (`upgrade.md`). A twin is served at `/<name>/index.md`, not at its source path, so such a link no longer reaches a page from the twin's URL; before, the URL-style links did. An agent reading a twin gets the GitHub paths instead. Rewriting links in twins would be a theme change and is left open.
- TRANSLATING.md asks for file links. A link that names a folder or a site URL fails the docs rules before a push.
