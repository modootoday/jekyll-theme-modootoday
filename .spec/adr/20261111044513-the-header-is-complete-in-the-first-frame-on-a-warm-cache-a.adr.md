---
id: adr:modootoday/20261111044513
title: "The header is complete in the first frame on a warm cache: a body class for the sidebar width and a render-blocking expect link"
status: active
created: 2026-11-11T04:45:13Z
updated: 2026-11-11T04:45:38Z
rel:
  governs: [_layouts/default.html, _sass/modootoday/components/doc/_sidebar.scss, test/system/audit/first-paint.mjs]
  depends_on: [adr:modootoday/20261030083001]
---

# The header is complete in the first frame on a warm cache: a body class for the sidebar width and a render-blocking expect link

## Context

The first-paint contract (adr:modootoday/20261030083001) holds on a cold load, but its 2026-11-11 amendment left one case open: when the theme sheets are cached (HTTP cache with the `max-age=600` GitHub Pages sends, or the PWA worker) and the HTML streams in slowly, the browser paints as it parses. The docs home ends its header at byte 21,008 of 50,023, after 7.6 KB of nav and 2.5 KB of language menu, so the first frames showed the title and nav without search, language or theme toggle. The site title also sat 40 px off, because the shell width came from `.mt-body:has(.mt-has-sidebar)` and `.mt-has-sidebar` is parsed inside `main`, after the header.

Measured on remote Chrome 152 (Cloudflare Browser Rendering), docs home reached by the logo click from the Install guide, service workers blocked, header band = pixels of the top 64 px that differ between the first new frame and the settled page:

| Build | Warm 1280 (light, dark, stored dark) | Warm 390 | Warm FCP ms | Cold header | Cold FCP ms |
|---|---|---|---|---|---|
| Before | 2,502 / 0 / 2,879 px | 208 / 302 / 302 px | 776-812 | 0 at 1280, unchanged at 390 | 848-916 |
| Body class only | 0-631 px | 24-302 px | 756-840 | same | 828-1,492 |
| Body class and expect link | 0 / 0 / 0 px | 0 / 0 / 0 px | 800-872 | same | 820-1,020 |

Warm runs use 50 KB/s for the HTML: at the audit's 200 KB/s the 21 KB arrive in one parser chunk and no partial frame showed (0 px in every build). CLS stayed under 0.003 in every run; the anchor CLS was 0.

## Decision

- `layouts/default.html` prints `mt-body-sidebar` on `body` when the page's layout chain sets `mt_sidebar: true` (the doc layout does) and the site has a sidebar (`mt_sidebar` from `config.html`). `.mt-body.mt-body-sidebar` gives the doc width at the same specificity as the `:has()` rule, which stays as a separate rule (a selector list would drop both in a browser without `:has`) so a site that overrides `_layouts/default.html` keeps the wide doc shell in a minor release; it only matches once the sidebar is parsed. The class is public (Public API, page shell).
- Every page carries `<link rel="expect" href="#mt-main" blocking="render">` after the stylesheets. Chromium (124+) holds the first frame until the `main` start tag is parsed, which is after the whole header. It costs about 40 ms of FCP on the warm 50 KB/s run and nothing on the cold run, where the render-blocking sheets arrive after the header anyway. Other browsers ignore the unknown `rel`; `main` is in every page of the default layout, and without it rendering resumes when parsing ends.
- Shrinking the header markup before the controls (moving the nav or the language list) was not needed after these two and is not done: it would change the header's DOM order, which the keyboard and screen-reader order follow.
- The first-paint audit runs every case twice: cold (`Network.setCacheDisabled`) at 200 KB/s as before, and warm (theme files cached by the Install page, the audit server sending `max-age=600` like GitHub Pages) at 50 KB/s. Service workers stay blocked; the anchor step runs only cold, since a route turns the HTTP cache off.

## Consequences

- Firefox and Safari can still paint a partial header on a warm cache and a slow line, though no longer at the wrong width on doc pages.
- A site that overrides `_layouts/default.html` keeps the doc width through the `:has()` rule, as before; to also get the width in the first frame it prints the class. A layout of its own that renders the doc sidebar sets `mt_sidebar: true` in its front matter.
- The audit takes twelve runs instead of six.
