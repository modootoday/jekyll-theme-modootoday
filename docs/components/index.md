---
nav_order: 0
layout: examples
title: Components
description: Every component with the Markdown that produces it and the live result.
examples: [alerts, alerts-content, cards, cards-3, buttons, tabs, badges, keyboard, accordion, steps, steps-headings, timeline, timeline-list, figure, tables, code]
sections:
  - alerts
  - alerts-content
  - {c: features, name: cards, cols: 2}
  - {c: features, name: cards-3, cols: 3}
  - {c: cta, name: buttons}
  - {c: tabs, name: tabs}
  - badges
  - keyboard
  - {c: accordion, name: accordion}
  - {c: steps, name: steps}
  - {c: steps, name: steps-headings}
  - {c: timeline, name: timeline}
  - {c: timeline, name: timeline-list}
  - figure
  - tables
  - code
  - navigation
  - language-switcher
  - theme-toggle
  - icons
  - search
  - breadcrumb-toc
  - pagination
  - posts
  - status
  - {c: cta, name: next}
---
# Components

Each component is ordinary Markdown. Every example below shows the Markdown source and then the live result the theme renders from that same source, in the light or dark scheme you are using. Copy a source block into your page to get the same result. On github.com each one falls back to the plain element.

[Open the kitchen sink](kitchen-sink/) [Configuration](../guides/configuration/)

## Alerts

`status:available` A GitHub alert becomes a callout with a localized title. Five types: note, tip, important, warning and caution. Screen readers announce each one as a note (`role="note"`).

> [!NOTE]
> Useful information that users should know, even when skimming.

> [!TIP]
> Helpful advice for doing things better or more easily.

> [!IMPORTANT]
> Key information users need to know to achieve their goal.

> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems.

> [!CAUTION]
> Advises about risks or negative outcomes of certain actions.

## Alerts with content

An alert can hold lists and code. Leave nothing after the marker on its line.

> [!TIP]
> Before you publish:
>
> - run `modootoday-check`
> - preview with `bundle exec jekyll serve`

## Cards

`status:available` In a `c: features` section, each list item that starts with **bold** text becomes a card. `cols: 2` or `cols: 3` sets the grid; narrow screens show one column.

- **Plain Markdown** — Pages read well on github.com too.
- **With a badge** — Cards can carry status. `status:available`

## Cards in three columns

The same list with `cols: 3`.

- **Alerts** — Five alert types.
- **Tabs** — Accessible code tabs.
- **Search** — Client-side search.

## Buttons

`status:available` A paragraph that holds only links becomes buttons. The first link is the primary one. It works in the hero (before the first `##`) and in a `c: cta` section.

[Get started](../guides/install/) [Read the configuration](../guides/configuration/)

## Tabs

`status:available` In a `c: tabs` section, each `###` heading followed by a code block becomes a tab. Use at least two. Keyboard: arrow keys move between tabs, and Home and End jump to the first and last. Without JavaScript every block stays visible under its heading.

### macOS

```sh
brew install ruby
```

### Linux

```sh
sudo apt install ruby-full
```

## Badges

`status:available` Code spans with a known prefix become badges: status (available, partial, planned) and tag. The status symbol is hidden from screen readers, and the label is read instead.

`status:available` `status:partial` `status:planned`

`tag:beta`

## Keyboard keys

`status:available` A code span that starts with kbd and a colon becomes keyboard keys. Join keys with `+` and no spaces.

Open search with `kbd:Ctrl+K`, or press `kbd:/`.

## Accordion

`status:available` In a `c: accordion` section, each `###` heading becomes a button that shows or hides the content under it (`aria-expanded`). Enter or Space toggles it. Without JavaScript every answer stays visible.

### Does it work without JavaScript?

Yes. Every answer stays visible under its question.

### Can an answer hold code?

```sh
bundle exec jekyll serve
```

## Steps

`status:available` In a `c: steps` section, an ordered list becomes numbered steps.

1. Add the theme to `_config.yml`.
2. Write `index.md` in plain Markdown.
3. Run `bundle exec jekyll build`.

## Steps as headings

Use `###` headings instead of a list when a step needs more than one line.

### Install

Add `remote_theme` and the plugin.

### Publish

Push to `main` and turn on GitHub Pages.

## Timeline

`status:available` In a `c: timeline` section, `###` headings become points on a line.

### Install

Alerts, sections, cards and tabs.

### Check

Theme toggle, breadcrumb and table of contents.

## Timeline as a list

An ordered list works too.

1. Install: alerts, sections and cards.
2. Write: design tokens and navigation.
3. Check: theme toggle and steps.

## Figure

`status:available` A paragraph with only an image, followed by a paragraph with only *emphasis*, becomes a figure with a caption. Alt text is required.

![A Markdown source on the left becomes a styled page on the right](../assets/images/sample.svg)

*Markdown on the left, the rendered page on the right.*

## Tables

`status:available` GFM tables scroll sideways on small screens instead of overflowing the page.

| Key | Default | Description |
|---|---|---|
| `color_scheme` | `auto` | follow the OS or force light or dark |
| `badges` | `true` | turn status code spans into badges |

## Code blocks

`status:available` Fenced code blocks are highlighted and get a copy button at the end of the first line. A long line scrolls, and the block can be reached with the keyboard.

```ruby
Jekyll::Hooks.register :site, :post_write do |site|
  puts "Built #{site.pages.size} pages"
end
```

## Navigation

`status:available` The header menu comes from `_data/nav/main.yml`. An entry with `items:` becomes a dropdown group on wide screens, and narrow screens get a menu button. Esc closes an open menu. The result is the header of this page.

```yaml
- {title: Install, url: /install/}
- {title: Components, url: /components/}
- title: More
  items:
    - {title: Public API, url: /api/}
```

## Language switcher

`status:available` With `languages:` and `language_switcher: header`, the header gets a globe button that opens a list of languages. It stays the same width however many languages you add. Each language is named in its own language, and the current one has `aria-current`. Esc closes the list. The result is the globe in the header of this page.

```yaml
modootoday:
  languages: [en, ko, ja]
  language_switcher: header
```

## Theme toggle

`status:available` The header button switches between light and dark and remembers the choice. Use `color_scheme` to fix one scheme. The result is the button in the header of this page.

```yaml
modootoday:
  color_scheme: auto   # auto | light | dark
```

## Icons and logo

`status:available` The theme draws its icons (globe, sun and moon, search, alert types, copy, edit, previous and next, external link, breadcrumb arrows) as inline SVG in `currentColor`, so they follow the light or dark scheme and need no extra requests. Icons are hidden from screen readers; each icon-only button has its own name. Arrows that point a direction flip in right-to-left pages. Set `logo` to put the modootoday mark (or your own image) before the site title, and `favicon` to add the matching browser icons. The result is the header and footer of this page.

```yaml
modootoday:
  logo: brand        # brand | /assets/img/logo.svg
  favicon: brand     # brand | /favicon.ico
```

## Search

`status:available` Client-side search over a `search.json` file, in the header (`role="search"`). Press `kbd:Ctrl+K` or `kbd:/` to focus it. Add a `search.json` file at the site root to turn it on: copy [the one this site uses](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/docs/search.json). The result is the search box in the header of this page.

## Breadcrumb and table of contents

`status:available` Doc pages get a breadcrumb from the URL, and a table of contents from the `##` and `###` headings: at the side on wide screens and in a folding box on narrow ones. Both are added by the layout, so there is no source to write. Leave out `breadcrumb` or `toc` from `components` to turn them off. The result is at the top and side of this page.

```yaml
modootoday:
  components: [callout, badge, hero, cta, card, tabs, code-copy, nav, pagination, theme-toggle]
```

## Previous and next

`status:available` Pages listed in the nav get previous and next links in nav order. Set `pagination: false` in front matter to hide them. The result is at the bottom of this page.

```yaml
---
title: Components
pagination: false
---
```

## Posts and archives

`status:available` `layout: post` shows the date, author and tags (`p.mt-post-meta`).

```yaml
---
layout: post
title: Hello
date: 2026-10-30
author: Won
tags: [release]
---
```

## Status legend

| Badge | Meaning |
|---|---|
| `status:available` | shipped and stable |
| `status:partial` | works with known limits |
| `status:planned` | on the roadmap |

## Next

[Kitchen sink](kitchen-sink/) [Configuration](../guides/configuration/)
