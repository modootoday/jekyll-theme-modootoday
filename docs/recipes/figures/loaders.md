---
nav_order: 20
title: Diagram and math loaders
description: Render Mermaid diagrams and KaTeX math in the browser with the built-in loaders or your own, and what each one asks of your CSP and privacy.
---
# Diagram and math loaders

These options draw diagrams and math in the reader's browser. [Math and diagrams](../math-diagrams/) compares them with static figures, which need no script.

## Built-in loaders

Both are off by default. Turn one on in `_config.yml` with a URL to a renderer **at an exact version** and its [Subresource Integrity](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity) hash, or with a path to a copy on your own site:

```yaml
modootoday:
  mermaid:
    enabled: true
    src: https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.min.js
    integrity: sha384-…   # the hash of that exact file
    theme: auto           # auto (follows the page's light or dark mode), default, dark, neutral, forest
  math:
    enabled: true
    engine: katex
    src: https://cdn.jsdelivr.net/npm/katex@0.19.0/dist/katex.min.js
    css: https://cdn.jsdelivr.net/npm/katex@0.19.0/dist/katex.min.css
    integrity: {js: sha384-…, css: sha384-…}
    auto_render_src: https://cdn.jsdelivr.net/npm/katex@0.19.0/dist/contrib/auto-render.min.js
    auto_render_integrity: sha384-…
    inline: false
```

- **Only where needed.** The tags load only on pages that contain a block: `language-mermaid` for Mermaid, a ```` ```math ```` fence or a `$$` block for math. Set `mermaid: false` or `math: false` in a page's front matter to skip one page.
- **No hash, no load.** A CDN URL without `integrity` (or a non-https URL) loads nothing, and `modootoday-check` reports an error. The checker also requires an exact version in the URL (`@11.4.1`, not `@11` or `@latest`) and reports any other third-party script or stylesheet in the built pages.
- **Self-hosted.** A path such as `/assets/vendor/mermaid.min.js` loads from your own site (`relative_url` is applied; `integrity` is optional). For KaTeX, copy `katex.min.js`, `katex.min.css`, the `fonts/` folder and `contrib/auto-render.min.js` from the `katex` package into one folder, and `base: /assets/vendor/katex/` stands for `src`, `css` and `auto_render_src`; a key you set still wins.
- **Readable without JavaScript.** The source stays on the page as a code block until the renderer replaces it, and stays if a diagram or formula fails to parse.
- **Light and dark.** With `theme: auto`, diagrams use Mermaid's `dark` theme when the page is dark (the theme toggle or the visitor's system setting) and redraw when it changes. With reduced motion requested, diagram animations are off. A diagram wider than the column scrolls inside its own keyboard-focusable region.
- Each loader is a small separate script (`assets/js/modootoday-mermaid.js`, `assets/js/modootoday-math.js`) with its own size budget, not part of the core script.

### Math notation

Use a ```` ```math ```` fence or a `$$` block on its own lines; both are the standard notation and render on github.com too. A `$$` block needs `auto_render_src`; without it only fences render. Inline `$…$` renders only with `inline: true`, because a `$` in ordinary prose (prices, shell variables) would otherwise turn into math. With `inline: false`, `modootoday-check` warns about inline `$…$` in your pages. kramdown prints `$$…$$` written inside a sentence as inline math, which renders whenever `auto_render_src` is set.

### CSP and privacy

A CDN changes your Content Security Policy and your visitors' privacy:

- **CSP.** Add the CDN origin to `script-src` (both), to `style-src` (KaTeX's stylesheet) and to `font-src` (KaTeX's fonts). Mermaid also writes `<style>` into each diagram, so it needs `style-src 'unsafe-inline'` wherever you host it. A self-hosted copy keeps `'self'` for scripts, styles and fonts. See [Content Security Policy](../../csp/).
- **Privacy.** Each visitor's browser requests the files from the CDN, so the CDN receives the visitor's IP address, the page address (as referrer) and the time. Self-hosting avoids this; mention the CDN in your privacy notice if you use one.
- **Availability.** With a CDN, the blocks render only while that CDN is reachable; the source code block remains otherwise.

## Your own loader

Use this when you need control the built-in loaders do not give. Copy the renderer's files into your site, then load them from `_includes/footer-custom.html`. Wrap the tags in a Liquid `if page.math` (or `if page.mermaid`) block so they load only on pages that set that key in front matter.

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

Mermaid writes `<style>` elements into each SVG, so a strict `style-src 'self'` blocks its styling. Either use [static diagrams](../math-diagrams/#static-diagrams), or allow inline styles for that page only and keep scripts strict:

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
