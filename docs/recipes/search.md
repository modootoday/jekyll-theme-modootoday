---
nav_order: 25
title: Search
description: Turn on the header search, choose what the index holds and how queries match, and let readers filter a long list or table.
---
# Search

The header search reads one `search.json` file that Liquid builds, so it works on classic GitHub Pages with no plugin and no outside service. The search script and the file load the first time a reader focuses the search box or presses `/` or Ctrl+K, so a visit that never searches loads neither.

## Turn it on

Add a `search.json` file at the site root, with `layout: null` in its front matter and one line that includes `modootoday/search.json`. Copy [the one this site uses](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/docs/search.json).

The search box appears in the header of every page. Pages with `search: false` in their front matter, and pages without a title, are left out.

## Choose what is indexed

```yaml
modootoday:
  search:
    words: 2000                 # words of each page's text; 0 keeps all of it (default 300)
    collections: [skills]       # collections with output: true, indexed after the posts
    fields: [description, tags] # front matter searched together with the text
    exclude: [/v1/]             # URL prefixes left out, such as an old version of the docs
```

A longer text finds more, but every reader downloads the whole index on the first search. `modootoday-check` warns when the built `search.json` is over 1.5 MB.

## Choose how queries match

```yaml
modootoday:
  search:
    match: terms   # every word, in any order (default substring: the query as typed)
    compact: true  # also compare with the spaces taken out
    results: 12    # default 8
```

Matching ignores case and compares text in Unicode NFC, so an accent or a Hangul syllable written in two ways matches. `compact: true` is for languages such as Korean where spacing varies: 검색량조회 finds 검색량 조회 and the other way round. Pages whose title matches come first, and results in the page's language come before the others. There is no stemming and no search by initial consonants.

Without these keys the search works as before: the query as typed, 8 results, 300 words per page.

A query starts at two characters, or at one Han, kana or Hangul character (표, 表). In the results, every matched word in the title and the snippet is a `mark`, underlined on a light tint of the primary colour; restyle it with `.mt-search-results mark`. The results close when Tab moves focus out of the search box, and Esc clears the query.

## Filter a list or table

For a long list or table on one page, add `filter:` to its `sections:` item, or to the front matter of a page without `sections:`:

```yaml
sections:
  - {name: tools, filter: true}
  - {name: plans, filter: {facet: 3}}
```

A field above the first list or table of that section shows only the items that contain every word typed, with the same matching as `compact: true`, and says how many are shown. `facet: 3` adds a button for each value in the table's third column. On a directory page, `filter_text: true` adds the same field above the cards. Without JavaScript every item stays visible. See the [filter demo](../../layouts/demo/filter/).
