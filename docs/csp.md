---
title: Content Security Policy
description: Run the theme under a strict CSP without unsafe-inline.
---
# Content Security Policy

The theme loads its CSS and scripts from files under `assets/`. Two things are inline by default:

| Inline item | When | Strict option |
|---|---|---|
| Pre-paint theme script (avoids a flash of the wrong colour scheme) | `theme-toggle` is on and `color_scheme: auto` | `modootoday.csp: strict` loads `assets/js/modootoday/theme-init.js` as a blocking script instead |
| `<style id="mt-tokens">` | `modootoday.tokens` or `tokens_dark` is set | move the overrides into your own Sass (`--mt-primary: …` on `:root`) and remove the keys |

With both handled, this policy works:

```text
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:
```

GitHub Pages cannot send response headers. A `<meta http-equiv="Content-Security-Policy">` tag in `_includes/head-custom.html` works for these directives. If you keep the inline script, allow it by hash instead; the hash changes only when the script changes, which `CHANGELOG.md` announces.

To add math or diagrams under this policy, see [Math and diagrams](../math-diagrams/).
