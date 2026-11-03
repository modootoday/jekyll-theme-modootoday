---
id: adr:modootoday/20261103012754
title: "Site module scripts load by name on the pages that use them, behind a poster"
status: active
created: 2026-11-03T01:27:54Z
updated: 2026-11-03T01:43:23Z
rel:
  governs: [_includes/modootoday/assets/site-scripts.html, _includes/modootoday/pages/hero/poster.html]
---

# Site module scripts load by name on the pages that use them, behind a poster

## Context

Sites moving to GitHub Pages want hero and section visuals drawn by JavaScript (a canvas, an animated SVG). The theme had `visual:` includes but no way to load a site script on one page only, and a visual that appears only after its script runs makes a late, unstable largest contentful paint. The core sheet has under 400 bytes of headroom.

## Decision

- `modootoday.scripts` maps a name to `{src, css, preload, element}`, site paths only; `script: <name>` on `hero:` or a section item loads that entry on that page only. `assets/site-scripts.html` writes, in `<head>` after the site sheets and once per name, the `css` link and the `<script type="module">` with the theme's `?v=` query, and a `modulepreload` per `preload` path without the query, because the browser matches the hint against the import URL, which has none. Unknown names and non-site paths print nothing. `element` is validated for the widget host that comes later and prints nothing now.
- `poster:` takes the `hero.image` shape and becomes `img.mt-visual-poster`, first in the visual column, `alt=""` (the module's drawing is decorative and the text stays in the page). The hero's poster gets `fetchpriority="high"`; a section's gets `loading="lazy"`, since it is below the fold and must not compete. srcset URLs get the baseurl. `width` and `height` are required by the checker so the box is reserved.
- The column is the module's root: `.mt-section-visual` in a split item, `div.mt-visual` outside split (printed only with `script:` or `poster:`, so other pages are byte-identical), with `data-mt-script=<name>`. The module draws into `.mt-visual-stage` after the poster, which the theme places over the poster's box, and sets `data-mt-ready` to hide the poster. It must do nothing under reduced motion. Without the module the poster simply stays, so a failed module degrades to a picture.
- The CSS (four rules) goes to a new context sheet, `visual`, linked by registry probes on the poster class and `data-mt-script`, not to the core sheet or the showcase hero bundle. It is a component name that is always included, like `lists`, `bleed` and `terminal`, so `css: bundle` folds it in.
- A split item with `script:` or `poster:` needs no `visual:`; `visual: code` with either is an error.
- The `scripts` key joins `config/keys/delivery.rb` (site files reaching the page) instead of a new file, because `config/keys/` holds the 12-file maximum. Script files are checked in the build, like `site_css`; posters in the source or the build.
- The demo lives in the docs site (`layouts/demo/orbit`, en, ko, ja), not in `example/`, because the CSP audit, Lighthouse and visual runs build the docs. Its poster is a WebP, not an SVG: Chrome does not count low-entropy images, and a small SVG at hero size falls below that line, so it would not be the LCP element.

## Consequences

Pages without `script:` or `poster:` render byte-identical HTML (checked with `diff -r` on the example site, Jekyll 4 and the Pages builder, and the docs site). A site adds a module without shadowing a layout and keeps a strict CSP, since module scripts are same-origin files. The visual contract (`data-mt-script`, `.mt-visual-stage`, `data-mt-ready`) is public API from here on.
