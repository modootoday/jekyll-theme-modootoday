---
nav_order: 30
title: Starter demo showcase
description: Show a bar or a pill on a starter's live demo that names the theme and links back to its documentation, and keep it out of every copy.
---
# Starter demo showcase

The `modootoday.showcase` setting, one row of the [Configuration](../../guides/configuration/) table, is described here in full.

A starter's live demo can show a bar that names the theme and the starter and links back to the theme's documentation. It belongs to the demo build only: put it in a second config file that only the demo deploy layers over `_config.yml`, so a site made from the starter never shows it. The GitHub Pages builder reads only `_config.yml`, so a workflow using it merges the demo file into `_config.yml` before the build. The theme's starters do this in a workflow step guarded by `if: github.repository == '<owner>/<repo>'`, so forks and repositories created from the template build without the showcase.

```yaml
# _config.demo.yml: jekyll build --config _config.yml,_config.demo.yml
modootoday:
  showcase:
    enabled: true
    style: bar            # bar (default) or pill
    starter: blog         # names the starter in the label
    docs_url: https://modootoday.github.io/jekyll-theme-modootoday/
    use_url: https://github.com/<owner>/<repo>/generate   # optional
```

On classic GitHub Pages, build in a GitHub Actions workflow (Settings > Pages > Source: GitHub Actions) and merge the file in a guarded step before the builder runs. These are the steps the starters' `pages.yml` uses; the step after the build puts `_config.yml` back, so the check that follows sees the site's own settings:

```yaml
# .github/workflows/pages.yml: steps of the build job, around the build
- name: Layer the demo config
  if: github.repository == '<owner>/<repo>'
  run: |
    cp _config.yml "$RUNNER_TEMP/_config.yml"
    ruby -ryaml -rdate -e '
      read = ->(f) { YAML.safe_load_file(f, permitted_classes: [Date, Time], aliases: true) || {} }
      merge = ->(a, b) { a.merge(b) { |_, x, y| x.is_a?(Hash) && y.is_a?(Hash) ? merge.(x, y) : y } }
      File.write("_config.yml", YAML.dump(merge.(read.("_config.yml"), read.("_config.demo.yml"))))'
- uses: actions/jekyll-build-pages@v1   # the classic GitHub Pages builder
  with:
    source: .
    destination: ./_site
- name: Restore _config.yml
  if: github.repository == '<owner>/<repo>'
  run: mv "$RUNNER_TEMP/_config.yml" _config.yml
```

- **Bar** (`style: bar`, the default): a 44 px bar above the header with the theme name, the starter name, a Documentation link, a Use this starter link (when `use_url` is set) and a button that hides it. The sticky header and the offset of anchor targets move down by its height. Below 40rem (640 px) only the theme name, a Docs link and the button remain. In a window less than 30rem (480 px) tall, such as a phone held sideways or 200% zoom, the bar scrolls away with the page.
- **Pill** (`style: pill`): a floating pill at the bottom centre with the theme name, the starter name, a Docs link and the button. The page gets bottom padding, so the pill never covers the last line, the back-to-top link or the safe area.
- **Colors** are the page's, inverted: a dark bar on a light page and a light one on a dark page. The `brand` token colors only the mark.
- **Links** come only from the config. They open in a new window, show the arrow, and their names say so.
- **Focus order**: the showcase is a region named "Theme showcase", and its links come right after "Skip to content".
- **Hiding** lasts for the rest of the visit in that tab (`sessionStorage`). A small script in `<head>` reads it before the page is drawn, so the next page shows neither the bar nor its space, and nothing moves. Without JavaScript, or when storage is blocked, the showcase stays.
- **Search engines**: with the showcase on, every page carries `<meta name="robots" content="noindex">`, because a demo's sample text is what every site made from the starter begins with. Sitemaps still list the pages, but noindex wins, and a Lighthouse SEO audit of a demo build reports the pages as blocked from indexing.
- **Labels** follow the page language. `starter` picks the `showcase.starters.<name>` label, which the theme has for `docs`, `blog` and `landing`; for another starter add that key to `_data/i18n/<lang>.yml`, or the label names only the theme.
- `modootoday-check` checks the key in `_config.yml` and `_config.demo.yml`, warns when `_config.yml` itself turns it on, and, in a build that shows the showcase, warns about pages without the noindex tag. A site that keeps `_config.demo.yml` but builds without it gets no warning.
