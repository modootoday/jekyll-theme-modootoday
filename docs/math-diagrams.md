---
title: Math and diagrams
description: Add KaTeX math and Mermaid diagrams without bundling them in the theme and without breaking a strict CSP.
---
# Math and diagrams

The theme ships no math or diagram renderer. A ```` ```math ```` or ```` ```mermaid ```` fence renders as a code block on your site, and GitHub renders it on github.com. To render them on your site, pick one of the two options below. Both work with the [strict CSP](../csp/) `default-src 'self'; script-src 'self'; style-src 'self'`.

| Option | Works on | CSP | JavaScript in the browser |
|---|---|---|---|
| Render at build time and commit the output | classic GitHub Pages, Jekyll 4, any host | strict, nothing to add | none |
| Self-host the renderer and load it from `_includes/footer-custom.html` | classic GitHub Pages, Jekyll 4, any host | strict for KaTeX; Mermaid needs `style-src 'unsafe-inline'` | yes |

Do not load a renderer from a CDN: it adds a third-party origin to `script-src`, and the page depends on that origin being up.

## Render at build time

This is the recommended option. The page ships static SVG, so it works without JavaScript, prints well and passes a strict CSP.

### Diagrams

Render each Mermaid source to SVG with the Mermaid CLI, commit the SVG, and reference it as a figure. Keep the source next to it so the diagram can be regenerated.

```sh
npx -y @mermaid-js/mermaid-cli -i assets/diagrams/flow.mmd -o assets/diagrams/flow.svg -b transparent
```

```markdown
![Markdown becomes a page, then the checker verifies the build](../assets/diagrams/flow.svg)

*The build flow.*
```

An image-only paragraph followed by an emphasis-only paragraph becomes a figure with a caption. Write the alt text as the diagram's meaning, not "diagram". For dark mode, render a second SVG with `-t dark` and pick it with `<picture>` and `prefers-color-scheme`, or use a transparent background with mid-tone colours that read on both.

### Math

Render formulas to HTML with KaTeX once, in a script you run before committing, or in a Jekyll 4 build on GitHub Actions. Then serve KaTeX's CSS and fonts from your own site. In the examples, replace `/your-base` with your site's `baseurl` (or use Jekyll's `relative_url` filter):

```sh
npm install katex
mkdir -p assets/katex && cp -r node_modules/katex/dist/katex.min.css node_modules/katex/dist/fonts assets/katex/
```

```html
<!-- _includes/head-custom.html -->
<link rel="stylesheet" href="/your-base/assets/katex/katex.min.css">
```

KaTeX's static output is plain HTML and CSS classes, so `style-src 'self'` is enough.

## Self-host a renderer

Use this when you cannot add a build step. Copy the renderer's files into your site, then load them from `_includes/footer-custom.html`. Wrap the tags in a Liquid `if page.math` (or `if page.mermaid`) block so they load only on pages that set that key in front matter.

### KaTeX in the browser

```html
<link rel="stylesheet" href="/your-base/assets/katex/katex.min.css">
<script defer src="/your-base/assets/katex/katex.min.js"></script>
<script defer src="/your-base/assets/js/math.js"></script>
```

```js
// assets/js/math.js: render ```math fences (kramdown: pre > code.language-math)
document.querySelectorAll("code.language-math").forEach((code) => {
  const box = document.createElement("div");
  katex.render(code.textContent, box, { displayMode: true, throwOnError: false });
  code.closest("div.highlighter-rouge, pre").replaceWith(box);
});
```

Add `math: true` to the page's front matter. The script is a file, so `script-src 'self'` is enough.

### Mermaid in the browser

Mermaid writes `<style>` elements into each SVG, so a strict `style-src 'self'` blocks its styling. Either render at build time (above), or allow inline styles for that page only and keep scripts strict:

```html
<script defer src="/your-base/assets/mermaid/mermaid.min.js"></script>
<script defer src="/your-base/assets/js/diagrams.js"></script>
```

```js
// assets/js/diagrams.js
document.querySelectorAll("code.language-mermaid").forEach((code) => {
  const box = document.createElement("pre");
  box.className = "mermaid";
  box.textContent = code.textContent;
  code.closest("div.highlighter-rouge, pre").replaceWith(box);
});
const dark = document.documentElement.dataset.theme === "dark" || (!document.documentElement.dataset.theme && matchMedia("(prefers-color-scheme: dark)").matches);
mermaid.initialize({ startOnLoad: false, theme: dark ? "dark" : "default", securityLevel: "strict" });
mermaid.run();
```

Keep `securityLevel: "strict"`: it disables click handlers and HTML labels inside diagrams.

## Checklist

- The source stays in the Markdown, so github.com and agents reading the [Markdown twin](../agents/) still see it.
- No third-party origins in your CSP.
- Every diagram has alt text or a caption that states what it shows.
- Load renderers only on pages that need them.
