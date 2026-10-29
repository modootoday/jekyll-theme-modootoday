---
nav_order: 10
title: Kitchen sink
description: Every implemented component and variant on one page, for visual review.
sections:
  - alerts
  - {c: features, name: cards-2, cols: 2}
  - {c: features, name: cards-3, cols: 3}
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
---
# Kitchen sink

Every component the theme ships, in every variant. The same file is readable on github.com, which shows the fallback.

[Primary action](../../guides/install/) [Secondary](../) [Third link](https://github.com/modootoday/jekyll-theme-modootoday)

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
> - a second item with a [link](../)
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

Paragraph text with **bold**, *italic*, ~~strikethrough~~, `code` and a [link](../). Footnotes work too.[^1]

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
