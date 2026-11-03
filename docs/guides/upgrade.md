---
nav_order: 60
nav_title: Migrate
title: Migrate and upgrade
description: Move a site from another Jekyll theme, adopt the theme in an existing project, and upgrade between versions.
---
# Migrate and upgrade

## From another theme

1. Replace `theme:` or `remote_theme:` with this theme (see [Install](../install/)) and pin a version.
2. Set `layout: doc` as a default in `_config.yml`, or keep your own layouts and include only the parts you need.
3. Keep page bodies as they are. GitHub alerts, tables and fenced code already work. Remove raw HTML and Liquid from bodies where you can; `modootoday-check` lists what is not portable.
4. Move colours and fonts into `modootoday.tokens` instead of overriding CSS selectors.
5. Run `jekyll build` and `modootoday-check SRC _site`, then fix what it reports.

Common mappings: minima `layout: page` and just-the-docs `layout: default` become `layout: doc`; callouts made with an `include note.html` tag become `> [!NOTE]`; badges written in HTML become `` `status:available` `` code spans.

## Adopting in an existing project

| Method | Use when | Updates |
|---|---|---|
| Gem (`theme:`) | the site has a `Gemfile` (Jekyll 4 or the `github-pages` gem) | `bundle update jekyll-theme-modootoday` |
| `remote_theme:` | classic GitHub Pages without a `Gemfile` | change the `@vX.Y.Z` tag |
| Copy-in | you need to fork layouts or cannot add a dependency | copy `_layouts`, `_includes`, `_sass` and `assets` from a tagged release and record the version; you merge updates by hand |

Prefer the gem or `remote_theme:` pinned to a tag. Copy-in loses upgrades and checker guarantees for the files you change.

## Markdown twins

Pick one of three ways to publish the agent-readable twin of each page:

- **Stub files** (default, classic GitHub Pages): one small `<page>.md.txt` per page.
- **Plugin** (Jekyll 4 or GitHub Actions): `plugins: [jekyll-theme-modootoday]` creates twins and `llms.txt` without stubs.
- **Source mode** (classic GitHub Pages, no stubs): `modootoday.twins: source` with pages that have no front matter. Classic GitHub Pages serves the raw copy as `text/markdown; charset=utf-8`, identical to the source (see RULES.md §5a for the limits).

Switching between them does not change page bodies. See [Agents](../agents/) and section 5a of `RULES.md`.

## From jekyll-seo-tag

To let the kit write the SEO tags instead of `jekyll-seo-tag`:

1. Remove `jekyll-seo-tag` from `plugins:` and the `Gemfile`, and the `seo` tag from `_includes/head-custom.html`.
2. Remove `seo: false` and `hreflang: true` from `modootoday:`. The kit writes the canonical link, the `hreflang` alternates and Open Graph again; delete any alternate links you added by hand, so no page lists them twice.
3. Set the browser bar colour with `modootoday.theme_color` (see [Configuration](../configuration/)). The kit writes two `theme-color` tags by default, one for light and one for dark; remove any `theme-color` tag of your own, or the page has three.
4. The kit writes only `twitter:card` (`summary_large_image` when the page has an image). It reads no `twitter:` setting; put a `twitter:site` meta tag in `_includes/head-custom.html` if you need one.
5. Rebuild and run `modootoday-check SRC _site`: the warning about jekyll-seo-tag JSON-LD should be gone.

## Upgrading

Read `CHANGELOG.md` for every version you skip. The [Public API](../../reference/api/) page lists the documented names. After upgrading, run `modootoday-check --strict`.

| From | To | What to do |
|---|---|---|
| a build from the repository before 1.0.0 | 1.0 | pin `~> 1.0` or `@v1.0.0`; run `modootoday-check --strict` |
| 1.0 or 1.1 | 1.2 | pin `~> 1.2` (or the newest `v1.2.x` tag with `remote_theme`); the new section and hero options (`bleed:`, `reveal:`, `c: split` with `visual:`) are opt-in, so pages need no edits; run `modootoday-check --strict` |
| 1.2 | 1.3 | pin `~> 1.3` (or `@v1.3.0` with `remote_theme`); the `reference` sidebar (`sidebar: true`) and package table (`packages:`) are opt-in, so pages need no edits; run `modootoday-check --strict` |
| 1.3 | 1.4 | pin `~> 1.4` (or `@v1.4.1` with `remote_theme`); `packages_compact` and `packages_position` are opt-in, and `reference` pages now convert alerts like `doc`, so pages need no edits; run `modootoday-check --strict` |
| 1.4 | 1.5 | pin `~> 1.5` (or `@v1.5.0` with `remote_theme`); the default look changes (see below), and pages need no edits; run `modootoday-check --strict` |

If your pages come from a pre-1.0 draft that allowed fewer `sections:` items than `##` headings, add a plain name (such as `notes`) for each remaining heading: the count must now match, and `modootoday-check` reports the page and both numbers.

A `resume` or `links` page that sets `name:` showed its file name (`resume.md`) as the person's name, because Jekyll replaces `name:` on a page with the file name. Rename the key to `display_name:`; until you do, the title is shown and `modootoday-check` warns.

### The 1.5 look

1.5 makes the default style flat and neutral: a neutral gray ramp, an opaque 4rem header, no shadows except on menus and search results, plain bordered callouts, buttons and cards without lift, headings at weight 600 and body text at 1.75 line height. Headings are smaller and balanced (h1 2rem, h2 1.5rem, h3 1.25rem, at every width), Korean, Japanese and Chinese pages use a font stack of their own, and Japanese text breaks between phrases where the browser supports it. The token names are the same; only their values change. `modootoday.theme_color` now defaults to `#0a0a0a` in dark mode, the new page background. To keep the 1.4 colours, sizes and shadows, put the old values in the token bridge:

```scss
// _sass/modootoday/_site.scss
$mt-overrides-base: (heading-weight: 650, line-height: 1.7, measure: 46rem, container: 76rem, header-height: 3.75rem,
  space-section: 3rem);
$mt-overrides: (
  foreground: #1f2328, card-foreground: #1f2328, accent-foreground: #1f2328, muted: #f6f8fa, accent: #eff2f5,
  muted-foreground: #59636e, status-planned: #59636e, code-comment: #59636e, border: #d1d9e0,
  shadow-sm: 0 1px 2px rgba(31, 35, 40, 0.06), shadow: 0 6px 20px -6px rgba(31, 35, 40, 0.16)
);
$mt-overrides-dark: (
  background: #0d1117, primary-foreground: #0d1117, foreground: #e6edf3, card-foreground: #e6edf3,
  accent-foreground: #e6edf3, muted: #1a212b, card: #1a212b, accent: #151b23, muted-foreground: #9198a1,
  status-planned: #9198a1, code-comment: #9198a1, border: #3d444d,
  shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3), shadow: 0 8px 24px -6px rgba(0, 0, 0, 0.5)
);
```

Set `modootoday.theme_color: {light: "#ffffff", dark: "#0d1117"}` as well. The header blur, the callout stripe and tint and the button lift are gone and come back only with your own `site_css`.

The header stays one 4rem row at every width. Below 64rem its links move into a menu button (`.mt-nav-sheet`), and the inline copies of group links (`.mt-nav-flat`) are gone, so rules a site wrote for `.mt-nav-flat` now target `.mt-nav-sheet`. Headings no longer set `scroll-margin-top`; anchors land below the header through `scroll-padding-top` on the page.
