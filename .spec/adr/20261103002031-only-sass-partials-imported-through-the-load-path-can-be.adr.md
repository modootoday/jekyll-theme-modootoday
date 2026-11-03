---
id: adr:modootoday/20261103002031
title: "Only Sass partials imported through the load path can be shadowed, and the docs say so"
status: active
created: 2026-11-03T00:20:31Z
updated: 2026-11-03T00:20:49Z
rel:
  governs: [_sass/modootoday, test/consumer/consumer_test.rb]
---

# Only Sass partials imported through the load path can be shadowed, and the docs say so

## Context

The Customize guide said any file in the theme's `_sass/` can be replaced by a site file at the same path. Jekyll does put the site's `_sass/` before the theme's on the Sass load path, but Dart Sass and Ruby Sass both resolve a relative `@import` next to the importing file first, so a partial the theme imports relatively always comes from the theme. That is why the token hook is imported as `modootoday/site`.

## Decision

- Measured on Jekyll 4.4 (jekyll-sass-converter 3, Dart Sass) and on the Pages builder (Jekyll 3.10, jekyll-sass-converter 1.5, Ruby Sass 3.7, theme loaded the way jekyll-remote-theme does), with every leaf partial shadowed at once with a marker rule and every importing partial shadowed alone. Both stacks gave the same answer.
- A site file wins for the partials the entry sheets import through the load path: `_site.scss`, `_access.scss` and the component partials under `components/` (the FAQ sheet imports `_details.scss` relatively and keeps the theme's). Settings, tools, tokens, base, layout and the per-layout sheets (`blog/`, `directory/`, `kit/`, `pages/`, ...) always come from the theme. A lone copy of `_core.scss`, `_sheet.scss`, a per-layout `_index.scss` or `_faq.scss` fails the build, since its relative imports are not beside it.
- The guide (en, ko, ja) says exactly this, names `site_css` and shadowing an `assets/css/` sheet as the ways to change the rest, and notes that component partials are internal. The imports stay as they are: making every partial shadowable would turn internal paths into API.
- `test/consumer/consumer_test.rb` builds the example site with a sample of both kinds shadowed, on whichever stack the bundle runs (CI runs both), and checks that a lone `_core.scss` copy fails.

## Consequences

The documentation matches both builders. A future change that imports a component partial relatively, or the hook through a relative path, fails the consumer test.
