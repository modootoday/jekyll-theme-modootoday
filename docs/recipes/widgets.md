---
nav_order: 28
title: Widgets
description: Place your own custom element in a page from Markdown, with text that readers without JavaScript get instead.
widget_props: {x-counter: {start: 10, step: 10, label: Add 10}}
---
# Widgets

A widget is a custom element of your own, such as a calculator or a live status box, placed in a page from Markdown. The theme ships no widget code. It places the element, hands it your settings, loads your module only on the pages that contain the element, and keeps a text fallback for readers without JavaScript, for github.com, for the page's Markdown twin and for `llms-full.txt`.

## Register the element

Add an entry to `modootoday.scripts` with the element your module defines:

```yaml
modootoday:
  scripts:
    counter: {src: /assets/js/widgets/x-counter.js, css: /assets/css/widgets/x-counter.css, element: x-counter}
```

- `element` is a custom element name: lowercase, with a hyphen, not starting with `mt-` (the theme's prefix), and not one of the names SVG and MathML reserve, such as `font-face`. Two entries cannot name the same element.
- `src` and `css` are site paths. A page that contains `<x-counter` gets the entry's sheet and `<script type="module">` in `<head>`, once, as with [module scripts](../../guides/customize/#module-scripts-and-posters). Module scripts are allowed by `script-src 'self'`, so a strict CSP needs no change.
- Pages without the element load nothing.
- The module and sheet URLs end in the theme's `?v=` query, as theme files and `site_css` sheets do, so a CDN can cache them for long. With the default `modootoday.asset_version: theme` the query changes only with the theme version; when you edit your own module between theme releases, set `asset_version: build`, which adds the commit ([Versioned asset URLs](../../guides/performance/#versioned-asset-urls)). Modules your entry imports keep plain URLs.

## Place it in a section

A `c: widget` section puts the element after the section's heading. The text after the heading is the fallback:

```yaml
sections:
  - c: widget
    name: counter
    widget: x-counter
    props: {start: 3, label: Count}
```

```markdown
## Counter

The counter starts at 3. Readers without JavaScript read this paragraph instead.
```

The theme writes:

```html
<x-counter class="mt-widget" data-props="{&quot;start&quot;:3,&quot;label&quot;:&quot;Count&quot;}">
  <div class="mt-widget-fallback"><p>The counter starts at 3. …</p></div>
</x-counter>
```

- `props` is a map of plain values (text, numbers, `true`, `false`). The element reads it as JSON from `data-props`.
- The section needs at least one paragraph after the heading. Write it so it holds up on its own: a sentence, a table of results or a link to a page that does the same job.

The [kitchen sink](../../components/kitchen-sink/#widget) has a counter section.

## Place it in a paragraph

A line holding only `widget:<element>` puts the element where the line is:

```markdown
`widget:x-counter`
```

Its props come from front matter, keyed by element: `widget_props: {x-counter: {start: 10, step: 10}}`. Its fallback is one sentence from the theme's catalog (`widget.fallback`, translated). Only an element that `modootoday.scripts` registers becomes a widget; any other `widget:` line stays a code span, and `modootoday-check` reports it. This page has one:

`widget:x-counter`

## Write the element

The contract between the theme and your module:

- Define the element with `customElements.define`. Until then, the theme shows `div.mt-widget-fallback`; once the element is defined (CSS `:defined`), it hides it. A module that fails or never loads leaves the fallback in place, with no `<noscript>`.
- Read the settings from `data-props`. [`readConfig`](../../guides/customize/#module-scripts-and-posters), a named export of the theme's `/assets/js/modootoday/dom/config.js`, parses it: `readConfig(this, {props: {}})`. Import it by a path relative to your module:

  ```js
  // assets/js/widgets/x-counter.js
  import { readConfig } from "../modootoday/dom/config.js";
  ```

- Add your controls after the fallback and leave the fallback in the element.
- Style your controls with the theme's tokens, such as `var(--mt-primary)` and `var(--mt-border)`, so they follow light and dark mode, and give them visible focus.

The counter on this page is a 30-line module, [x-counter.js](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/docs/assets/js/widgets/x-counter.js), with a 7-line sheet.

## What readers get

| Reader | Sees |
|---|---|
| A browser running your module | the element |
| JavaScript off, or the module blocked or failed | the fallback text |
| github.com, the Markdown twin, `llms-full.txt` | the section text, and the `widget:` line as code |

`modootoday-check` reports an element that no entry registers, props that are not plain values, a `c: widget` section without a paragraph and an `element` name the browser would reject.
