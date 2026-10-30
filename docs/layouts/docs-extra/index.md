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

## Changelog

Each release lists its changes under the five category headings, in that order, with labels in the page language. Items are Markdown. `modootoday-check` reports any other key, so a typo such as `fix:` does not vanish silently.

## Glossary

Terms are sorted for you and grouped by first letter, with a letter bar that links only to letters in use. Every term gets an anchor (`id:` or a slug of the term), and the page data lists each one as a DefinedTerm.

## Course

Lesson `minutes` add up to the total shown under the title and to `timeRequired`. The course provider is the site publisher; a `description:` is required.

## Checks

`modootoday-check` requires the list each layout is built on, a valid `status`, a `text` for each term, no duplicate terms, a `url` for each hub card, whole-number `minutes` and `pages`, and a 10- or 13-digit `isbn`.
