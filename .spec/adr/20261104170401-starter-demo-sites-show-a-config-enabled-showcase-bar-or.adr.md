---
id: adr:modootoday/20261104170401
title: Starter demo sites show a config-enabled showcase bar or pill
status: active
created: 2026-11-04T17:04:01Z
updated: 2026-11-04T17:16:45Z
rel:
  governs: [example/starters.yml]
  evidence: [research:modootoday/20261104170510]
---

# Starter demo sites show a config-enabled showcase bar or pill

## Context

The docs site holds its own demo pages. The starter templates in `example/` are real sites, so they can serve as the live demos instead, the way Bootstrap Themes, Tailwind templates and Jekyll theme authors link to running demos. A visitor who lands on a starter demo then needs a way back to the theme's canonical site (https://modootoday.github.io/jekyll-theme-modootoday/). Theme marketplaces do this with a bar on the preview.

Options weighed:
- A `?showcase=1` URL trigger, rejected. It needs client-side persistence across the demo's links, inserts the bar after first paint (layout shift), and invites a URL-supplied link target.
- An iframe preview frame, rejected. It breaks the demo's own sticky header, focus order and full-screen behaviour.
- A config-enabled bar rendered by Liquid, chosen.

The maintainer approved the bar from a mockup and asked for the floating pill as an option.

## Decision

- The theme renders the showcase only when the site config enables it. A URL parameter never turns it on, and its link targets come only from config:
  ```yaml
  modootoday:
    showcase:
      enabled: true
      style: bar          # bar (default) | pill
      starter: blog       # names the starter in the label (i18n key)
      docs_url: https://modootoday.github.io/jekyll-theme-modootoday/
      use_url: https://github.com/<owner>/<starter>/generate   # optional
  ```
- A starter's demo deploy layers a demo-only file (`jekyll build --config _config.yml,_config.demo.yml`). A site copied from the starter does not inherit the showcase.
- `style: bar` (the default):
  - **Placement and offsets:** a sticky bar 44px tall, above the theme header. The header's sticky top and the page's `scroll-padding-top` add the bar height, so the bar never covers the header or an anchor target.
  - **No layout shift:** it is part of the server-rendered page, so it takes its space from the first paint.
  - **Colour:** inverted against the site (a dark bar on a light page, a light bar on a dark page). The accent appears only on the mark.
  - **Contents:** the theme name and the starter name; a "Documentation" link (`docs_url`); a "Use this starter" link (`use_url`, when set); and a dismiss button.
  - **Mobile:** below 40rem only the theme name, one documentation link and the dismiss button remain.
- `style: pill`:
  - **Placement:** a floating pill at the bottom centre, with the same contents shortened to the label and the documentation link.
  - **Spacing:** the page gets bottom padding of the pill height plus its gap, so the last content is never covered. The pill clears the back-to-top control and the bottom safe-area inset.
- **Both styles:**
  - **Links:** open in a new tab, with an arrow mark and an accessible name that says so.
  - **Landmark and focus:** the showcase is a named `region` landmark. Its links come before the skip link in focus order.
  - **Dismissal:** dismiss hides it for the rest of the visit in that tab (sessionStorage), and with the bar the header offset returns to 0. Without JavaScript, or when storage is unavailable, the showcase simply stays.
  - **Rendering and accessibility:** forced colours, 200% zoom and reduced motion are respected.
- **Assets:** the showcase sheet and its small dismiss module are linked only on pages where the showcase is enabled, so the core sheet does not grow. Each has its own gzip cap in the asset registry.
- **Labels:** the strings live in the theme's i18n catalogs (en, ko, ja).

## Consequences

- The starters gain a `_config.demo.yml` and a demo deploy.
- The docs link to the starter demos in a new tab instead of hosting their own demo pages. Still to decide, in the research for this change: which docs demo pages move, the redirects from their old URLs, where the starter demos are hosted, how demo pages are kept out of search results (noindex or canonical), and which release carries the change.
- The visual, lighthouse and docs QA suites follow the demo pages to the starter builds.
- The configuration reference and the upgrade guide document `modootoday.showcase` in all three languages.
- Mockup used for approval: bar and pill, light and dark, 1440 and 360px.
