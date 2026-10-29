---
title: Accessibility
description: Keyboard use, screen readers, safe areas, touch targets, high contrast and reduced motion.
---
# Accessibility

The theme aims for WCAG 2.2 AA with no setup. This page lists what it does for readers and the two settings that change it.

## Keyboard

| Key | Where | Action |
|---|---|---|
| `Tab` | any page | the first stop is "Skip to content", which moves focus to the main text |
| `/` or `Ctrl`+`K` (`Cmd`+`K` on macOS) | any page with search | focus the search box (`/` is ignored while you type in a field) |
| `↓` `↑` | search results | move between results and back to the box |
| `Esc` | search | leave the results, or clear the box |
| `←` `→` `Home` `End` | tabs | switch tabs; left and right follow the reading direction in right-to-left pages |
| `↓` `↑` `Esc` | language menu, nav "More" menu, page actions | move between items; `Esc` closes and returns focus |
| `Tab` | wide code blocks and tables | a block that scrolls sideways becomes a labelled region you can focus and scroll with the arrow keys |

Focus is always visible. Inside tabs, panels and scroll regions the focus ring is drawn inside the box so it is not clipped.

## Screen readers

Landmarks (header, navigation, main, footer), the current page in navigation, breadcrumbs and the language menu (`aria-current`), and labels for icon buttons, code blocks and tables are built in. Labels follow `lang:` in 23 languages (see [Configuration](../configuration/#languages)). Icons are decorative unless they carry a label.

## Phones and tablets

- **Safe areas.** Pages extend under the notch, rounded corners and home indicator, and the header, side padding and footer move clear of them.
- **Touch targets.** On touch screens, links in the header, menus, tabs, copy buttons and pagination are at least 44 px tall, and the search box uses 16 px text so iOS does not zoom.
- **Browser colour.** The address bar matches the page background in light and dark mode.

## High contrast and motion

- With Windows high contrast (forced colours), icon buttons and the search box keep visible borders.
- With "reduce motion" turned on, transitions and animations are off.

## Settings

```yaml
modootoday:
  viewport_fit: auto           # default: cover (draw under the notch with safe-area padding)
  theme_color: {light: "#ffffff", dark: "#0d1117"}  # or one "#hex", or false
```

| Key | Default | Effect |
|---|---|---|
| `viewport_fit` | `cover` | `auto` keeps the page inside the safe area, letting the browser add the margins |
| `theme_color` | page background | colour of the browser bar; one `"#hex"`, `{light, dark}`, or `false` to drop the tags |

Your own CSS can read the insets as `--mt-safe-top`, `--mt-safe-right`, `--mt-safe-bottom` and `--mt-safe-left`.

## Your content

The theme cannot fix the content itself. Write descriptive link text and image `alt` text, keep one `#` heading per page and do not skip heading levels.
