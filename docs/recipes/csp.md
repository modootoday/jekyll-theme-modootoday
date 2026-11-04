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
| Pre-paint theme script (avoids a flash of the wrong colour scheme) | `theme-toggle` is on and `color_scheme: auto` | `modootoday.csp: strict` loads `assets/js/modootoday/chrome/theme-init.js` as a blocking script instead |
| `<style id="mt-tokens">` | `modootoday.tokens` or `tokens_dark` is set | move the values into the token bridge (`_sass/modootoday/_site.scss`, see [Brand tokens](../brand-tokens/)) and remove the keys |

With both handled, this policy works:

```text
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:
```

Table columns aligned with `:---`, `:---:` or `---:` are the exception: kramdown writes the alignment as a `style` attribute, which this policy blocks, so those columns fall back to the default alignment and the browser reports a violation. Leave column alignment out on pages served with this policy.

GitHub Pages cannot send response headers. A `<meta http-equiv="Content-Security-Policy">` tag in `_includes/head-custom.html` works for these directives. If you keep the inline script, allow it by hash instead; the hash changes only when the script changes, which `CHANGELOG.md` announces.

The theme's docs QA serves sample pages, among them the [strict CSP demo](../../layouts/demo/csp/), with this policy as a response header and fails on any violation.

To add math or diagrams under this policy, see [Math and diagrams](../math-diagrams/).
