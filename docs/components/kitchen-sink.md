---
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
  - keyboard
  - tables
  - code
  - typography
  - {c: cta, name: cta}
---
# Kitchen sink

Every component the theme ships, in every variant. The same file is readable on github.com, which shows the fallback.

[Primary action](../../install/) [Secondary](../) [Third link](https://github.com/modootoday/jekyll-theme-modootoday)

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

- **Short** — one line.
- **Longer card** — a card with a longer description that wraps over several lines to check spacing, line height and alignment across the grid.
- **With a badge** — cards can carry status. `status:available`
- **With a link** — read the [install guide](../../install/).

## Cards in three columns

- **Alerts** — five GitHub alert types. `status:available`
- **Tabs** — accessible install tabs. `status:partial`
- **Search** — planned for a later release. `status:planned`
- **Tokens** — colors, radius and fonts. `status:available`
- **Sass** — one partial per component. `status:available`
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

Tag and version badges: `tag:beta` `tag:experimental` `since:0.3`

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

### 0.1.0

Alerts, sections, cards, tabs, status badges and the checker.

### 0.2.0

Design tokens, the `modootoday:` block, navigation and code copy.

### 0.3.0

Theme toggle, breadcrumb, table of contents, accordion, steps and figures.

### 0.4.0

Timeline, keyboard keys, client search and the post layout.

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

[Get started](../../install/) [Read the rules](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/RULES.md)
