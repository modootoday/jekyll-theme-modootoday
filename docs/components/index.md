---
nav_order: 0
layout: examples
title: Components
description: Every component with the Markdown that produces it and the live result.
examples: [alerts, alerts-content, cards, cards-3, buttons, tabs, badges, keyboard, accordion, steps, steps-headings, timeline, timeline-list, figure, tables, code, code-titles, progress, embeds, loading, filetree, details, faq, params, linkcards, quote, gallery, pricing, subscribe]
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
  - code-titles
  - progress
  - embeds
  - loading
  - {c: filetree, name: filetree}
  - {c: details, name: details}
  - {c: faq, name: faq}
  - {c: params, name: params}
  - {c: linkcards, name: linkcards}
  - {c: quote, name: quote}
  - {c: gallery, name: gallery}
  - {c: pricing, name: pricing, recommended: 2}
  - {c: subscribe, name: subscribe}
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

## Code titles and diffs

`status:available` A line holding only a code span that starts with file and a colon, right before a fenced block, becomes the block's title bar. A `diff` block tints added and removed lines and keeps the plus and minus signs.

`file:_config.yml`

```yaml
theme: jekyll-theme-modootoday
```

```diff
- remote_theme: old/theme
+ theme: jekyll-theme-modootoday
```

## Progress

`status:available` A code span that starts with progress and a colon, followed by a whole number from 0 to 100, becomes a labelled progress bar with the value as text.

Translation `progress:60`

## Embeds

`status:available` A paragraph holding only a code span that starts with embed and a colon, then an https URL and an optional title, becomes a lazy 16:9 frame that keeps its space while it loads.

`embed:https://modootoday.github.io/jekyll-theme-modootoday/assets/images/sample.svg Sample page drawing`

## Loading and skeletons

`status:available` Code spans that start with loading or skeleton and a colon become a spinner, a thin top bar or a placeholder (text, card, image, avatar, row). Each one has `role="status"` and a Loading label for screen readers, and the motion stops when the reader asks for reduced motion. Their styles are an optional sheet that only pages using them load.

`loading:spinner`

`skeleton:avatar`
`skeleton:text`
`skeleton:card`

## File tree

`status:available` In a `c: filetree` section, a nested list draws a folder tree. Items that hold a nested list are folders.

- docs
  - _config.yml
  - index.md
  - ko
    - index.md

## Details

`status:available` In a `c: details` section, each `###` heading becomes a native disclosure. It opens and closes without JavaScript.

### What does it need?

Nothing but the browser.

## FAQ

`status:available` A `c: faq` section works like details. For FAQPage structured data, add a `schema:` block (see [Structured data](../guides/structured-data/)).

### Is the theme free?

Yes, under the MIT license.

### Does it run on GitHub Pages?

Yes, with the github-pages gem.

## Parameter table

`status:available` In a `c: params` section, a table lists options: name, type, default, description. A cell holding only `required` shows a Required badge.

| Name | Type | Default | Description |
|---|---|---|---|
| `title` | string | `required` | Page title |
| `cols` | number | 2 | Card columns |

## Link cards

`status:available` In a `c: linkcards` section, list items that start with a link become cards. The whole card is the link target.

- [Install](../guides/install/) — Add the theme to a site.
- [Configuration](../guides/configuration/) — Every setting in one place.

## Quote

`status:available` In a `c: quote` section, a quote whose last line starts with an em dash gets that line as its attribution.

> The docs read well on github.com and on the site.
>
> — A theme user

## Gallery

`status:available` In a `c: gallery` section, a list of images becomes a thumbnail grid. Each thumbnail opens a full-size view without JavaScript. Every image needs alt text.

- ![Theme logo](../assets/images/sample.svg)
- ![Theme mark](../assets/modootoday/favicon.svg)

## Pricing

`status:available` In a `c: pricing` section, each `###` heading is a plan with a price, a feature list and a link. The `recommended` parameter marks one plan with a Recommended label.

### Free

**$0**

- One site

[Start](../guides/install/)

### Team

**$12**

- Ten sites
- Support

[Choose Team](../guides/install/)

## Subscribe

`status:available` A `c: subscribe` section prints its text and an email form that posts to the address in `modootoday.subscribe.action`. Without that setting it shows only the text.

Get one email when a release ships.

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
