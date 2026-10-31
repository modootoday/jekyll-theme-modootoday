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

If your pages come from a pre-1.0 draft that allowed fewer `sections:` items than `##` headings, add a plain name (such as `notes`) for each remaining heading: the count must now match, and `modootoday-check` reports the page and both numbers.
