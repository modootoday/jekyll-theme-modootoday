---
id: adr:modootoday/20261104061808
title: "The checker reports unknown layouts and maps other themes' names, with no alias layouts"
status: active
created: 2026-11-04T06:18:08Z
updated: 2026-11-04T06:19:09Z
rel:
  governs: [lib/modootoday/check/native, lib/modootoday/schema/compat]
---

# The checker reports unknown layouts and maps other themes' names, with no alias layouts

## Context

Jekyll only warns when a page names a layout that does not exist and writes the page without one. Sites moving from Minimal Mistakes use `single`, `splash`, `posts` and others. Shipping alias layouts for every other theme would grow the public layout API for good.

## Decision

- A new checker rule group, `lib/modootoday/check/native/`, holds rules about plain Jekyll conventions. `sources.rb` reads, once per run, every source file with front matter under any Markdown extension or `.html`, posts and collection documents included; the page rules keep reading `*.md` only.
- `native/layouts.rb`: a layout named in front matter or in a `defaults` entry that is neither a site layout nor a theme layout is an error. Known names follow Jekyll's LayoutReader: every file under `_layouts`, named by its path without the last extension, so `docs/endpoint` is known. `none`, `null` and an empty value mean no layout.
- The message names the replacement from `lib/modootoday/schema/compat/<theme>.yml` (`layouts:` map; minima and Minimal Mistakes now). The same files are meant to feed the docs migration tables and a migration tool, so the mapping has one owner.
- `native/collections.rb`: for a collection with `output: true` whose label is a theme layout, whose site has no layout of that name and no `defaults` entry covering it, documents without `layout:` are a warning when that layout declares `mt_self_detail` and an error otherwise (a feed, blog or search layout cannot show one document). The message gives the `defaults` line to add.
- No alias layouts for other themes' names; `page` is the only Jekyll-standard name added.

## Consequences

Sites that relied on Jekyll writing pages without a layout now fail the check; that was always a broken page. Test `test/checker/native/native_check_test.rb` pins the messages, and every name a compat file maps to must be a theme layout.
