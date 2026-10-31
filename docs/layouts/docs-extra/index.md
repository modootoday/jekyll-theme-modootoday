---
title: Docs extras
description: Reference, changelog, roadmap, glossary, hub, course and book pages with one shared optional stylesheet.
nav_order: 50
---
# Docs extras

These layouts cover the pages around a manual. They load `modootoday-docs-extra.css` only on their own pages and add no JavaScript. Each reads a title and a `description:` (the lead); the page body comes after the generated part unless noted.

| Layout | Front matter | Structured data | Demo |
|---|---|---|---|
| `reference` | `members: [{name, signature, text, since, id}]` | TechArticle | [Reference](/jekyll-theme-modootoday/layouts/docs-extra/reference/) |
| `changelog` | `releases: [{version, date, url, added, changed, fixed, removed, security}]` | WebPage | [Changelog](/jekyll-theme-modootoday/layouts/docs-extra/changelog/) |
| `roadmap` | `items: [{title, status, text, url}]`, status `now`, `next` or `later` | WebPage | [Roadmap](/jekyll-theme-modootoday/layouts/docs-extra/roadmap/) |
| `glossary` | `terms: [{term, text, id}]` | DefinedTermSet | [Glossary](/jekyll-theme-modootoday/layouts/docs-extra/glossary/) |
| `hub` | `cards: [{title, text, url}]` | CollectionPage | [Hub](/jekyll-theme-modootoday/layouts/docs-extra/hub/) |
| `course` | `level`, `modules: [{title, lessons: [{title, url, minutes}]}]` | Course | [Course](/jekyll-theme-modootoday/layouts/docs-extra/course/) |
| `book` | `image`, `author`, `isbn`, `pages`, `chapters: [{title, url}]` | Book | [Book](/jekyll-theme-modootoday/layouts/docs-extra/book/) |
| `reference` with `sidebar: true` and `packages:` | `group` on members; `packages: [{name, version, text, url, links: [{label, url}]}]`, `packages_title` | TechArticle | [API reference](/jekyll-theme-modootoday/layouts/docs-extra/api/) |

## Changelog

Each release lists its changes under the five category headings, in that order, with labels in the page language. Items are Markdown. `modootoday-check` reports any other key, so a typo such as `fix:` does not vanish silently.

## Glossary

Terms are sorted for you and grouped by first letter, with a letter bar that links only to letters in use. Every term gets an anchor (`id:` or a slug of the term), and the page data lists each one as a DefinedTerm.

## Course

Lesson `minutes` add up to the total shown under the title and to `timeRequired`. The course provider is the site publisher; a `description:` is required.

## API sidebar and package table

Both are opt-in on the `reference` layout; a page without them renders as before. `sidebar: true` moves the member list into a side column that stays in view on wide screens (64rem and up). Members that share a `group:` are listed under that label, in the order the groups first appear; on narrow screens the same list sits above the page. `packages:` adds a table with one row per package (name, version and links, with the `text` under the name), before the body; on small screens each row stacks into a short card. A reference page with `packages:` may leave out `members:`. Both use CSS only.

## Checks

`modootoday-check` requires the list each layout is built on, a valid `status`, a `text` for each term, no duplicate terms, a `url` for each hub card, whole-number `minutes` and `pages`, and a 10- or 13-digit `isbn`.
