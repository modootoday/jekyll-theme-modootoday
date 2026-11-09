---
nav_order: 27
title: Generated pages
description: Give every record of a JSON or YAML data file its own page on classic GitHub Pages, with a filterable list of them all, and publish files byte for byte.
---
# Generated pages

A catalog, a plugin list or a glossary often starts as one data file. Jekyll 4 plugins can turn each record into a page, but classic GitHub Pages runs no plugin of yours, so every page needs a file in the repository. `modootoday-stubs --records` writes those files for you: one short page per record, with only front matter. The layout reads the rest of the record from the data file when the site builds.

The [docs starter's plugin list](https://modootoday.github.io/jekyll-theme-modootoday-docs-starter/plugins/ "new-window") shows it: five records from one JSON file, each with its own page, and a list you can filter.

## Declare a record set

Put the records in `_data/plugins.json` (or `.yml`): a list of objects, or a map with an `items` list. Each record needs a key that is safe in a URL (lowercase letters, digits, `.`, `_` and `-`) and a title.

```json
[
  {"slug": "lantern", "name": "Lantern", "summary": "Highlights the section a reader came to.", "category": "Reading", "version": "2.1.0", "tags": ["search"], "readme": "Lantern reads the words a reader searched for..."}
]
```

Then name the set in `_config.yml`:

```yaml
modootoday:
  records:
    plugins: {title: name, description: summary, facts: [category, version, tags], body: readme}
```

| Setting | Default | Meaning |
|---|---|---|
| `data` | the set name | the file in `_data` without its extension |
| `key` | `slug` | the field that names each record; it becomes the file name and the URL |
| `dir` | the set name | the folder the pages go in |
| `permalink` | `/<dir>/:key/` | the page URL; `:key` is replaced by the record key |
| `layout` | `detail` | `detail`, `reference`, or a detail layout such as `project` or `job` |
| `title` | `title` | the field copied into the page title |
| `description` | `description` | the field copied into the page description |
| `facts` | none | fields shown as a list of facts under the title; a list value shows as tags |
| `labels` | the field name | labels for the facts, such as `{version: Version}` |
| `body` | none | a Markdown field converted into the page body |
| `lang` | none | the page language, when the folder does not set it already |

## Write the pages

```sh
modootoday-stubs . --records           # list the pages it would create, update or delete
modootoday-stubs . --records --write   # write them
modootoday-stubs . --records --check   # CI: exit 1 when a page is missing, out of date or left over
```

Each page is `plugins/lantern.md`:

```yaml
---
layout: detail
title: "Lantern"
description: "Highlights the section a reader came to."
permalink: /plugins/lantern/
record: plugins/lantern
record_index: 0
twin: false
---
```

The title and description are copied because the page title, link previews, structured data and the search index read them before the layout runs. `record_index` is the record's place in the list, so a page finds its record without reading the others; if the list order changed and the pages were not written again, the page still finds its record, only more slowly, and `--check` reports the page as out of date. A record that is gone has its page deleted (`--no-prune` keeps it), and a page you wrote yourself is never replaced.

`--records=plugins,team` writes only the named sets. Record pages have no Markdown twin.

Run the command before each commit, for example from a Git pre-commit hook:

```sh
#!/bin/sh
modootoday-stubs . --records --write --quiet && git add -A -- plugins
```

## List the records

A directory page lists a set with `records:` instead of `items:` or `data:`. Each card links to its record page and takes its title and text from the fields the set names.

```yaml
---
title: Plugins
layout: integrations
records: plugins
filter_text: true
---
```

`layout: integrations` adds a button per `category`; `filter_text: true` adds a text filter. See [Directory layouts](../../layouts/directory/).

## Check the site

`modootoday-check` reports a record without a page, a page without a record and a page that is out of date, the same way `modootoday-stubs --records --check` does. In CI, run both:

```sh
modootoday-stubs . --records --check
modootoday-check . _site
```

## Publish files byte for byte

Files without front matter are copied as they are, so an `api/` folder of JSON files is a small static API. `modootoday-check . _site --byte-exact=api` proves it: every file under `api/` must be in the build with the same SHA-256. A folder under `_data/`, one listed in `exclude:` or starting with `_` or `.` (unless `include:` lists it), a file with front matter, and a Markdown or Sass file fail, because Jekyll would not copy them as they are.

## Limits

- Every record is a file in the repository. CI builds 1,000 records with the GitHub Pages builder on each change to the theme and fails if the build takes longer than 300 seconds, half the Pages limit.
- Adding a record anywhere but at the end of the list changes `record_index` in the pages after it, so `--write` rewrites them. Append new records to keep commits small.
- The search index holds a record page's title, description and front matter fields, not the body field.
