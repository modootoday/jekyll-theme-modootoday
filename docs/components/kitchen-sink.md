---
nav_order: 10
title: Kitchen sink
description: Every implemented component and variant on one page, for visual review.
sections:
  - alerts
  - {c: features, name: cards-2, cols: 2}
  - {c: features, name: cards-3, cols: 3}
  - {c: features, name: cards-4, cols: 4}
  - {c: tabs, name: tabs-2}
  - {c: tabs, name: tabs-many}
  - badges
  - {c: accordion, name: accordion}
  - {c: steps, name: steps-list}
  - {c: steps, name: steps-headings}
  - figure
  - {c: timeline, name: timeline}
  - {c: timeline, name: timeline-list}
  - keyboard
  - tables
  - code
  - typography
  - {c: cta, name: cta}
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
---
# Kitchen sink

Every component the theme ships, in every variant. The same file is readable on github.com, which shows the fallback.

[Primary action](#) [Secondary](#) [Third link](#)

## Alerts

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

> [!NOTE]
> An alert with more content:
>
> - a list item with `inline code`
> - a second item with a link to the [components index](../)
>
> ```sh
> echo "code inside an alert"
> ```

## Cards in two columns

- **Short** — One line.
- **Longer card** — A card with a longer description that wraps over several lines to check spacing, line height and alignment across the grid.
- **With a badge** — Cards can carry status. `status:available`
- **With a link** — Read the [install guide](../../guides/install/).

## Cards in three columns

- **Alerts** — Five GitHub alert types. `status:available`
- **Tabs** — Accessible install tabs. `status:partial`
- **Search** — Example of a planned item. `status:planned`
- **Tokens** — Colors, radius and fonts. `status:available`
- **Sass** — One partial per component. `status:available`
- **Twins** — Markdown for agents. `status:available`

## Cards in four columns

- **Alerts** — Five GitHub alert types. `status:available`
- **Tabs** — Accessible install tabs. `status:partial`
- **Search** — Example of a planned item. `status:planned`
- **Tokens** — Colors, radius and fonts. `status:available`
- **Sass** — One partial per component. `status:available`
- **Twins** — Markdown for agents. `status:available`
- **Grid** — Four across on wide screens.
- **Rows** — Eight cards fill two rows.

## Tabs with two panels

### macOS

```sh
brew install ruby
gem install jekyll bundler
```

### Linux

```sh
sudo apt install ruby-full
gem install jekyll bundler
```

## Tabs with many panels

### Ruby

```ruby
puts "Hello"
```

### JavaScript

```js
console.log("Hello");
```

### Python

```python
print("Hello")
```

### Shell

```sh
echo Hello
```

### A tab with a much longer name

```yaml
greeting: Hello
```

## Status badges

Inline badges: `status:available` `status:partial` `status:planned`

Tag badges: `tag:beta` `tag:experimental`

| Feature | Status |
|---|---|
| Alerts | `status:available` |
| Tabs | `status:partial` |
| Search | `status:planned` |

## Accordion

### What is the kitchen sink for?

It shows every component in one place, so visual regressions are easy to spot.

### Does it work without JavaScript?

Yes. Without JavaScript every answer stays visible under its question.

### Can an answer hold code?

```sh
bundle exec jekyll serve
```

## Steps as a list

1. Add the theme to `_config.yml`.
2. Write `index.md` in plain Markdown.
3. Run `bundle exec jekyll build`.
4. Check the result with `modootoday-check`.

## Steps as headings

### Install

Add `remote_theme` and the plugin.

### Write

Create a page with front matter.

### Publish

Push to `main` and turn on GitHub Pages.

## Figure

![A Markdown source on the left becomes a styled page on the right](../../assets/images/sample.svg)

*An image-only paragraph followed by an emphasis-only paragraph becomes a figure with a caption.*

## Timeline

### Install

Alerts, sections, cards, tabs, status badges and the checker.

### Write

Design tokens, the `modootoday:` block, navigation and code copy.

### Check

Theme toggle, breadcrumb, table of contents, accordion, steps and figures.

### Publish

Timeline, keyboard keys, client search and the post layout.

## Timeline as a list

1. Install: alerts, sections, cards and tabs.
2. Write: design tokens and navigation.
3. Check: theme toggle, table of contents and steps.

## Keyboard keys

Open search with `kbd:Ctrl+K`, or `kbd:/` on its own. Copy with `kbd:Cmd+C`.

## Tables

| Key | Type | Default | Description |
|---|---|---|---|
| `badges` | boolean | `true` | Convert status code spans into badges |
| `color_scheme` | string | `auto` | Follow the operating system or force a scheme |
| `components` | list | all core components | Limit the CSS and JavaScript that are shipped to the browser |
| `tokens` | map | theme defaults | Override design tokens such as primary color, radius and font stacks |

| Left | Center | Right |
|:---|:---:|---:|
| a | b | 1 |
| longer cell | centered | 1,000 |

## Code

Inline `code`, a fenced block and a long line that scrolls:

```ruby
# frozen_string_literal: true
Jekyll::Hooks.register :site, :post_write do |site|
  puts "Built #{site.pages.size} pages into #{site.dest} with a deliberately long line to test horizontal scrolling"
end
```

```diff
- theme: minima
+ theme: jekyll-theme-modootoday
```

## Typography

Paragraph text with **bold**, *italic*, ~~strikethrough~~, `code` and a link to the [components index](../). Footnotes work too.[^1]

### Heading level 3

#### Heading level 4

1. Ordered item
2. Ordered item
   - nested bullet
   - nested bullet

- [x] task done
- [ ] task open

> A plain quote that is not an alert.

---

Text after a thematic break.

[^1]: A footnote.

## Call to action

[Get started](../../guides/install/) [Read the rules](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/RULES.md)

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

`status:available` A `c: faq` section works like details. For FAQPage structured data, add a `schema:` block (see [Structured data](../../guides/structured-data/)).

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

- [Install](../../guides/install/) — Add the theme to a site.
- [Configuration](../../guides/configuration/) — Every setting in one place.

## Quote

`status:available` In a `c: quote` section, a quote whose last line starts with an em dash gets that line as its attribution.

> The docs read well on github.com and on the site.
>
> — A theme user

## Gallery

`status:available` In a `c: gallery` section, a list of images becomes a thumbnail grid. Each thumbnail opens a full-size view without JavaScript. Every image needs alt text.

- ![A sunlit room with a plant and an armchair](../../assets/images/gallery/room.webp)
- ![Pink sand dunes under a low sun](../../assets/images/gallery/dunes.webp)
- ![Tropical leaves around a still pond](../../assets/images/gallery/leaves.webp)
- ![A wooden pier on a mountain lake](../../assets/images/news/travel-sm.webp)
- ![Wind turbines and solar panels on green hills](../../assets/images/news/energy-sm.webp)
- ![Fanned swatches in cream, violet and coral](../../assets/images/projects/brand.webp)

## Pricing

`status:available` In a `c: pricing` section, each `###` heading is a plan with a price, a feature list and a link. The `recommended` parameter marks one plan with a Recommended label.

### Free

**$0**

- One site

[Start the Free plan](#)

### Team

**$12**

- Ten sites
- Support

[Choose Team](#)

## Subscribe

`status:available` A `c: subscribe` section prints its text and an email form that posts to the address in `modootoday.subscribe.action`. Without that setting it shows only the text.

Get one email when a release ships.
