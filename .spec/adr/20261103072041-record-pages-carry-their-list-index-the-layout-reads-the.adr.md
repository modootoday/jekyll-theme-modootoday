---
id: adr:modootoday/20261103072041
title: Record pages carry their list index; the layout reads the record without scanning the data
status: active
created: 2026-11-03T07:20:41Z
updated: 2026-11-03T07:44:28Z
rel:
  governs: [_includes/modootoday/records]
---

# Record pages carry their list index; the layout reads the record without scanning the data

## Context

Classic GitHub Pages cannot make a page per data record, so each record needs a committed stub page. The feature design looked the record up with `site.data[...] | where: key, value | first`, once per page: a pass over every record on every page, O(pages × records). An earlier measurement put that pass at about 4.5 ms per page at 1,000 records on a bare site. The rest of the theme no longer scans `site.pages` per page, so the record lookup would be one of the few per-page passes left that grows with the site.

## Decision

- `modootoday-stubs --records` writes `<dir>/<key>.md` per record with `layout`, `title`, `description` (copied, because head tags, JSON-LD and `search.json` read them before the layout runs), `lang` when set, `permalink`, `record: <set>/<key>`, `record_index: <position in the list>` and `twin: false`. Values are written as JSON strings, a YAML subset, so any title is safe and the bytes do not depend on the YAML emitter.
- `_includes/modootoday/records/lookup.html` reads `site.data[<data>][record_index]` (or its `items` list) and keeps it when its key matches; only when it does not (the list was reordered and the stubs were not rewritten) does it fall back to `where`. The page stays right either way, and `--check` reports the stale stub. The include avoids nested bracket lookups such as `a[b[0]]`, which Liquid 4 resolves to nil.
- `detail`, `reference` and the layouts built on `detail` render the set's `facts` (labels from `labels` or the field name; lists as tags; values escaped, since data can come from anywhere) and its Markdown `body` field, only when `page.record` is set, so other pages build the same HTML.
- A directory page lists a set with `records: <set>`; each card and its JSON-LD list item link the record page, and take title and text from the fields the set names when the record has none of its own.
- Keys must match `/\A[a-z0-9][a-z0-9._-]*\z/` and be unique; a record without a title, a data file that is not a list, and a page at a stub path that has no `record:` front matter are data errors (exit 3). Orphans are found by their `record:` front matter, never by body text.
- `--records` with `--twins` or `--aliases` overlays the planned record pages on the page list, so one run plans the other stubs for new record pages and drops them for removed ones.
- `modootoday-check` runs the same plan (`Stubs::Plan` with `:records`) for its verdict and reports `record:` naming no declared set.

## Consequences

Measured with the classic builder image (github-pages 232) on a synthetic site (`test/system/bench/records.rb`: N records of about 300 words, one directory page listing them all), on a host 2.3 to 2.9 times slower than a Pages runner: 250 records 49.6 s, 1,000 records 223.6 s (198 and 224 ms per page, so close to linear), peak RSS 86 and 99 MiB. The same 1,000 records with every page falling back to `where` took 213.0 s: at this size the scan is below the noise of a shared host, so the index is kept for growth beyond 1,000 records, not for a measured gain today. The cost of the index is churn: inserting a record near the top of the list rewrites the stubs after it (`record_index` changes). CI runs the benchmark at 250 and 1,000 records and fails over 300 s.
