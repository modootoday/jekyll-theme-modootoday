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

| Feature | Status |
|---|---|
| Alerts | `status:available` |
| Tabs | `status:partial` |
| Search | `status:planned` |

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
