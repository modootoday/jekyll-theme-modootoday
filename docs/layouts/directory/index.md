---
title: Directory layouts
description: Card lists for projects, people, jobs, events, sponsors and integrations, with a filter that needs no JavaScript.
nav_order: 20
---
# Directory layouts

A directory page is your text followed by a list of cards. The cards come from `items:` in front matter or from a file in `_data`. These layouts load `modootoday-directory.css` only on their own pages and add no JavaScript unless you turn on the text filter.

| Layout | Cards show | Filter by | Structured data | Demo |
|---|---|---|---|---|
| `portfolio` | image, title, text, tags | `tags` | ItemList | [Portfolio](/jekyll-theme-modootoday/layouts/directory/portfolio/) |
| `team` | round photo, name, role | `group` | ItemList of Person | [Team](/jekyll-theme-modootoday/layouts/directory/team/) |
| `jobs` | title, location, type | `department` | ItemList | [Jobs](/jekyll-theme-modootoday/layouts/directory/jobs/) |
| `events` | date tile, title, place, calendar file | none | ItemList of Event | [Events](/jekyll-theme-modootoday/layouts/directory/events/) |
| `sponsors` | logo, name, tier | `tier` | ItemList | [Sponsors](/jekyll-theme-modootoday/layouts/directory/sponsors/) |
| `integrations` | logo, name, category, text | `category` | ItemList | [Integrations](/jekyll-theme-modootoday/layouts/directory/integrations/) |

`layout: directory` is the plain version: set `preset:` to one of the names above, or leave it out for simple cards.

On GitHub Pages, jekyll-default-layout gives a collection document without a layout the layout named like its collection, so `_portfolio/atlas.md` gets `portfolio`. A document with no `items:`, `data:` or `records:` is one item, not a list, so these layouts draw it as the matching detail page: `project` for `portfolio`, `job` for `jobs`, `event` for `events`, and `detail` for the others, with that page's structured data. `modootoday-check` warns until `defaults` name the layout for the collection.

## Items

```yaml
---
layout: team
items:
  - {name: Ada Kim, role: Founder, group: Leadership, image: /assets/ada.jpg, alt: "", url: /about/ada/}
  - {name: Ben Ito, role: Designer, group: Design}
---
```

Each item needs `title` or `name`. All items take `url`, `text`, `image`, `alt`, `width` and `height`; give `alt: ""` when the photo only repeats the name. Preset fields:

- `team`: `role`, `group`
- `jobs`: `department`, `location`, `type`
- `events`: `date` (required, `YYYY-MM-DD HH:MM`), `end`, `location`, `online: true` for an online event (then `url` is where it happens)
- `sponsors`: `tier`
- `integrations`: `category`
- `portfolio`: `tags` (a list)

To share a list between pages, put it in `_data/team.yml` and write `data: team` instead of `items:`. To give each item its own page as well, declare a record set and write `records: <set>`: every card then links to its record page (see [Generated pages](../../recipes/generated-pages/)).

## Filter

When the filter field has two or more values, a row of buttons appears above the cards. It is a group of radio buttons, so it works with the keyboard and screen readers announce the choice. Up to 12 values are shown. Set `filter: false` to hide it, or `filter: <field>` to filter by another field. In browsers without `:has()` every card stays visible.

Set `filter_text: true` to add a search field above the cards as well. It shows only the cards that contain every word typed and counts them, next to the field filter; it needs JavaScript, and without it every card stays visible.

## Events

Each event links to an `.ics` file built into the page, so visitors can add it to their calendar without a server. Dates use the site's `timezone`.
