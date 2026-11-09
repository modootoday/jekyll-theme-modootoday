---
nav_order: 20
nav_title: CSP
title: Content Security Policy
description: Run the theme under a strict CSP without unsafe-inline.
---
# Content Security Policy

The theme loads its CSS and scripts from files under `assets/`. Two things are inline by default:

| Inline item | When | Strict option |
|---|---|---|
| Pre-paint script (avoids a flash of the wrong color scheme, or of a showcase the reader hid) | `theme-toggle` is on and `color_scheme: auto`, or `modootoday.showcase` is enabled | `modootoday.csp: strict` loads `assets/js/modootoday/chrome/theme-init.js` as a blocking script instead |
| `<style id="mt-tokens">` | `modootoday.tokens` or `tokens_dark` is set | move the values into the [token bridge](../../guides/customize/#token-bridge) (`_sass/modootoday/_site.scss`; an example is in [Brand tokens](../brand-tokens/)) and remove the keys |

With both handled, this policy works:

```text
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:
```

Table columns aligned with `:---`, `:---:` or `---:` are the exception: kramdown writes the alignment as a `style` attribute, which this policy blocks, so those columns fall back to the default alignment and the browser reports a violation. Leave column alignment out on pages served with this policy.

GitHub Pages cannot send response headers. A `<meta http-equiv="Content-Security-Policy">` tag in `_includes/head-custom.html` works for these directives. If you keep the inline script, allow it by hash instead; the hash changes only when the script changes, which `CHANGELOG.md` announces.

The theme's docs QA serves sample pages, among them the [strict CSP demo](../../layouts/demo/csp/), with this policy as a response header and fails on any violation.

To add math or diagrams under this policy, see [Math and diagrams](../figures/math-diagrams/). [Static diagrams](../figures/math-diagrams/#static-diagrams) and [static math](../figures/math-diagrams/#static-math) as MathML need nothing added: the page shows each diagram as an image from your site and each formula as MathML, with no script or inline style. Static math as KaTeX HTML needs `style-src 'unsafe-inline'`, because KaTeX writes `style` attributes. [Charts](../figures/charts/) need nothing added either when Chart.js is a file on your site: it sizes the canvas through the CSSOM, which `style-src 'self'` allows, and the docs QA opens the charts page, hovers a chart and clicks its legend under this policy with zero violations.
